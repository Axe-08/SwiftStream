import argparse
import torch
import torchaudio
import jiwer
from pathlib import Path
from transformers import AutoModelForSpeechSeq2Seq, AutoProcessor
from utils.text_normalizer import TextNormalizer
from tqdm import tqdm

def load_data(data_dir: Path) -> (dict, dict):
    """Loads the mock data from wav.scp and text files."""
    data_dir = Path(data_dir)
    
    # 1. Load wav.scp (e.g., "sample_001 /path/to/sample.flac")
    wav_scp_path = data_dir / "wav.scp"
    audio_paths = {}
    with open(wav_scp_path, "r") as f:
        for line in f:
            if not line.strip():
                continue
            utt_id, path = line.strip().split(maxsplit=1)
            audio_paths[utt_id] = path
            
    # 2. Load text (e.g., "sample_001 THIS IS A TEST")
    text_path = data_dir / "text"
    references = {}
    with open(text_path, "r") as f:
        for line in f:
            if not line.strip():
                continue
            utt_id, text = line.strip().split(maxsplit=1)
            references[utt_id] = text
            
    print(f"Loaded {len(audio_paths)} audio files and {len(references)} transcripts.")
    return audio_paths, references

def load_audio(file_path: str):
    """Loads and resamples a single audio file."""
    try:
        waveform, sample_rate = torchaudio.load(file_path)
        
        # Resample to 16kHz, which Whisper expects
        if sample_rate != 16000:
            resampler = torchaudio.transforms.Resample(sample_rate, 16000)
            waveform = resampler(waveform)
            
        # Ensure mono channel
        if waveform.shape[0] > 1:
            waveform = torch.mean(waveform, dim=0, keepdim=True)
            
        return waveform.squeeze().numpy(), 16000
    except Exception as e:
        print(f"Error loading audio file {file_path}: {e}")
        return None, 16000

def main(args):
    print(f"--- Starting Baseline 1 (Batch Whisper) Evaluation ---")
    
    # --- 1. Load Data ---
    print(f"Loading data from: {args.data_dir}")
    audio_paths, references = load_data(args.data_dir)
    if not audio_paths:
        print("No data found. Exiting.")
        return

    # --- 2. Load Model & Processor ---
    model_id = "distil-whisper/distil-large-v2"
    print(f"Loading model: {model_id} (this may take a moment...)")
    
    try:
        device = torch.device(args.device)
        model = AutoModelForSpeechSeq2Seq.from_pretrained(model_id).to(device)
        processor = AutoProcessor.from_pretrained(model_id)
    except Exception as e:
        print(f"Error loading model: {e}")
        print("Please ensure you have an internet connection and 'transformers' is installed.")
        return

    # --- 3. Run Inference ---
    print(f"Running inference on device: {device}")
    normalizer = TextNormalizer()
    
    hypotheses_list = []
    references_list = []

    # Use tqdm for a progress bar
    for utt_id in tqdm(audio_paths.keys(), desc="Processing files"):
        if utt_id not in references:
            print(f"Warning: Missing transcript for {utt_id}. Skipping.")
            continue
            
        audio_file = audio_paths[utt_id]
        waveform, sample_rate = load_audio(audio_file)
        
        if waveform is None:
            continue
            
        # Process audio
        input_features = processor(
            waveform, 
            sampling_rate=sample_rate, 
            return_tensors="pt"
        ).input_features.to(device)
        
        # Run batch-mode generation
        predicted_ids = model.generate(input_features)
        
        # Decode
        transcription = processor.batch_decode(
            predicted_ids, 
            skip_special_tokens=True
        )[0]
        
        # Normalize and store
        hypotheses_list.append(normalizer(transcription))
        references_list.append(normalizer(references[utt_id]))

    # --- 4. Calculate WER ---
    print("\n--- Evaluation Complete ---")
    
    if not references_list:
        print("No valid pairs to compare.")
        return
        
    print(f"Reference:  '{references_list[0]}'")
    print(f"Hypothesis: '{hypotheses_list[0]}'")
    
    wer = jiwer.wer(references_list, hypotheses_list)
    
    print(f"\nFinal Word Error Rate (WER): {wer * 100:.2f}%")
    print("---------------------------------")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Run Baseline 1 (Batch Whisper) ASR Evaluation."
    )
    
    # Argument for data directory (Task 3.3)
    parser.add_argument(
        "--data_dir",
        type=str,
        default="./local_test_data",
        help="Path to the data directory containing wav.scp and text files."
    )
    
    # Argument for device (Task 3.3)
    parser.add_argument(
        "--device",
        type=str,
        default="cpu",
        help="Device to run inference on (e.g., 'cpu', 'cuda', 'cuda:0')."
    )
    
    args = parser.parse_args()
    main(args)