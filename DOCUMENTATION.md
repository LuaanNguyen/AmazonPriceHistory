# DOCUMENTATION.MD

New to Linux? Research Computing has created a guide at [The Linux Shell on the SOL Supercomputer](https://jyalim.github.io/sol-shell-novice/)

For a great reference on building procifiency with CLI tools, check out [The Missing Semester of Your CS Education](https://missing.csail.mit.edu/)

## How to replicate on SOL 

The paper defines an LLM-based bargaining benchmark between two agents - A _Buyer_ and a _Seller_ - who negotiate over real products from `AmazonhistoryPrice` dataset. 

We can deploy LLMs (e.g., Qwen2.5-7B, Mistral-7B, ChatGPT, etc.) using `vLLM` on SOL to run the Buyer-Seller simulation locally. 

### 1. Launch GPU Node 

``` bash 
interactive -p htc -t 2:00:00 --gres=gpu:a100:1
```

Wait for `sg###` login prompt - indicates GPU node access ID 

### 2. Load environment

``` bash 
module load mamba/latest
module load cuda-12.6.1-gcc-12.1.0

mamba create -n venv python=3.10 -y
source activate venv
```

### 3. Install dependencies 

``` bash 
pip install -r requirements.txt
```

### 4. Clone the this repo (if you haven't done already) 

``` bash 
git clone https://github.com/LuaanNguyen/AmazonPriceHistory 
cd AmazonPriceHistory
```

### 5. Provide API keys (optional) 

If you want to benchmark against `GPT-3.5` or `GPT-4`, create a `.env` file and add; 

``` .env
OPENAI_API_KEY="YOUR KEY HERE"
```

### 6. Start he vLLM server

Use the supplied script to launch the model server. It accepts two arguments: The path to your HF model folder ( or model name if you installed it locally) and the number of GPUs.

For example, with 1 GPU and `Mistral-7B-Instruct-v0.2`:

```
source start_vllm_server.sh mistralai/Mistral-7B-Instruct-v0.2 1
```
This starts the server on port `:8000` (default). 

### 7. Run the benchmark (Different Terminal)

The repo provides 2 shell scripts:
- `run_2stages.sh`: runs two session
    - (1) The local model as Buyer and `GPT-3.5 Turbo` as Seller
    - (2) `GPT-3.5 Turbo` as Buyer and the local model as Seller
- `run_3stages.sh`: adds a third session where the buyter uses __OG-narrator__.

Each script requires a model name, an output directory, and an experiment name.

For example, to run the two-stage benchmark with local model only (both Buyter and Seller) without using `GPT-3.5`, invoke `run_session.py` manually: 

``` bash 
# baseline: local model as Buyer; local model as Seller
python run_session.py results baseline 0.8 llamaAgent mistralai/Mistral-7B-Instruct-v0.2 buyer llamaAgent mistralai/Mistral-7B-Instruct-v0.2 seller

# with OG‑Narrator: local model as Buyer using OGNarratorAgent; local model as Seller
python run_session.py results ognarr 0.8 OGNarratorAgent mistralai/Mistral-7B-Instruct-v0.2 linear llamaAgent mistralai/Mistral-7B-Instruct-v0.2 seller
```

If you want to replicate the scripts exactly ( **With OpenAI keys**), run: 

``` bash 
source run_2stages.sh mistralai/Mistral-7B-Instruct-v0.2 ./results exp_oct29

# or, to include OG‑Narrator
source run_3stages.sh mistralai/Mistral-7B-Instruct-v0.2 ./results exp_oct29
```

These commands with create a `/results` folder and execute the buyer-seller sessions as defined in the scripts. 

### 8. Evaluate the results 

Once the runs finish, use the provided evaluation script:

``` bash 
python eval.py ./results
```

It writes a CSV summary at `eval_results.csv` and saves plots of normalized profit distribution. 
