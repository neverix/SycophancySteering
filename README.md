# Sycophancy Activation Steering

## Setup

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Then create a `.env` file with the following variables (see `.env.example`):

```
HF_TOKEN=huggingface_token_with_access_to_llama2
CLAUDE_API_KEY=api_key_for_claude (optional, only needed for LLM-enabled eval)
```

## Available commands

```bash
# Format datasets for generating steering vector and testing effect
python make_datasets.py --generate_test_split 0.8 --anthropic_custom_split 0.6 --n_datapoints 1200
# Generate steering vectors and optionally save full activations
python generate_vectors.py --layers 15 20 25 --save_activations
# Optionally, plot projected activations
python plot_activations.py --activations_pos_file activations/activations_pos_15_Llama-2-7b-hf.pt --activations_neg_file activations/activations_neg_15_Llama-2-7b-hf.pt --fname activations_proj_15_Llama-2-7b-hf.png --title "Activations layer 15"
# Apply steering vectors to model and test effect (--type can by one of "in_distribution", "out_of_distribution", "truthful_qa"), (--few_shot can be one of "positive", "negative", "unbiased", "none")
python prompting_with_steering.py --type in_distribution --layers 15 20 25 --multipliers -1.5 -1 0 1 1.5 --few_shot positive
# Plot results of activation steering experiment (use same arguments as the experiment)
python plot_results.py --type in_distribution --layers 15 20 25 --multipliers -1.5 -1 0 1 1.5 --few_shot positive
```

## Full replicable experiments

Scripts that can be run to replicate the experiments are in the `scripts/` folder.
Run `./scripts/generate_all_vectors.sh` first to generate steering vectors.

## Analysis / charts

`analysis/` contains scripts for Claude-enabled eval of out-of-distribution steering

## Running tests

I have added a few unit tests for some of the utility functions. To run them, simply run:

```bash
pytest
```