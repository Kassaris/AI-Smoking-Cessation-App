# lib/chatbot_backend/evaluate_with_deepeval.py

import os
import json
import csv
from dotenv import load_dotenv
from deepeval.test_case import LLMTestCase
from deepeval.metrics import AnswerRelevancyMetric, FaithfulnessMetric, ContextualPrecisionMetric
from deepeval.models.llms.openai_model import GPTModel
import openai

# Load environment variables from .env
#load_dotenv()

API_KEY = "OPENAI_API_KEY"

openai.api_key = API_KEY
os.environ["OPENAI_API_KEY"] = API_KEY  # <-- this is what DeepEval reads

# Paths

LOG_PATH = os.environ.get("RAG_LOG_PATH", "logs.jsonl")
OUT_CSV = os.environ.get("DEEPEVAL_OUT", "deepeval_report.csv")

from openai import OpenAI
client = OpenAI()



def evaluate_log_file(log_path=LOG_PATH, out_csv=OUT_CSV):
    rows = []

    

    # Initialize GPTModel (use a model your project has access to)
    or_model = GPTModel(
        model="gpt-4o-mini"  # fallback if gpt-4.1-mini isn't enabled for your project
    )

    metrics = {
        "answer_relevancy": AnswerRelevancyMetric(model=or_model),
        "faithfulness": FaithfulnessMetric(model=or_model),
        "contextual_precision": ContextualPrecisionMetric(model=or_model),
    }

    # Read logs.jsonl
    if not os.path.exists(log_path):
        raise FileNotFoundError(f"{log_path} does not exist. Please create it first.")

    with open(log_path, "r", encoding="utf-8") as f:
        for line in f:
            item = json.loads(line)

            # Safe LLMTestCase with fallback expected_output
            retrieved_context = item.get("retrieved_context", [])
            # truncate each string to 2000 chars to prevent metric errors
            retrieved_context = [s[:500] for s in retrieved_context]

            tc = LLMTestCase(
                input=item.get("input", "")[:250],
                actual_output=item.get("response", "")[:500],
                retrieval_context=retrieved_context,
                expected_output=item.get("expected_output", "")[:500]
            )

            # Store results for CSV
            result_row = {"input": item.get("input", "")[:200]}  # truncate input
            for name, metric in metrics.items():
                try:
                    result = metric.measure(test_case=tc)

                    if isinstance(result, float):
                        result_row[f"{name}_score"] = result
                       # result_row[f"{name}_reason"] = "returned float"
                    elif result is None:
                        result_row[f"{name}_score"] = None
                        result_row[f"{name}_reason"] = "metric returned None"
                    else:
                        result_row[f"{name}_score"] = getattr(result, "score", None)
                        result_row[f"{name}_reason"] = str(getattr(result, "reason", ""))[:300]

                except Exception as e:
                    result_row[f"{name}_score"] = None
                    result_row[f"{name}_reason"] = f"error: {e}"


            rows.append(result_row)

    # Write CSV
    if rows:
        keys = list(rows[0].keys())
        with open(out_csv, "w", newline="", encoding="utf-8") as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=keys)
            writer.writeheader()
            writer.writerows(rows)

    print(f"Finished evaluation. Wrote {len(rows)} rows to {out_csv}")



if __name__ == "__main__":
    evaluate_log_file()
