if [ ! -d "venv" ]; then
    echo "Creating venv"
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
else
    source venv/bin/activate
fi

# Generate datasets
echo "Generating datasets"
python make_datasets.py --generate_test_split 0.8 --anthropic_custom_split 0.6 --n_datapoints 1200

# Generate steering vector for layer 16
echo "Generating steering vectors"
python generate_vectors.py --layers 16 # Chat model vectors

# In-distribution tests
echo "In-distribution A/B question tests"
# Chat model -> Base model
python prompting_with_steering.py --type in_distribution --layers 16 --multipliers -1.5 -1 -0.5 0 0.5 1 1.5 --few_shot none --override_vector_model Llama-2-7b-chat-hf --use_base_model

# Out-of-distribution tests
echo "Out-of-distribution A/B question tests"
# Chat model -> Base model
python prompting_with_steering.py --type out_of_distribution --layers 16 --multipliers -1.5 -1 -0.5 0 0.5 1 1.5 --max_new_tokens 100 --few_shot none --override_vector_model Llama-2-7b-chat-hf --use_base_model

# Claude scoring
echo "Claude scoring"
python analysis/claude_scoring.py

# Plot results
echo "Plotting results"
python analysis/plot_results.py --multipliers -1.5 -1 -0.5 0 0.5 1 1.5 --type out_of_distribution --layers 16 --title "Applying chat model vector to llama 7b base - effect of steering on Claude score"
python analysis/plot_results.py --multipliers -1.5 -1 -0.5 0 0.5 1 1.5 --type in_distribution --layers 16 --title "Applying chat model vector to llama 7b base - effect of steering on behavior"