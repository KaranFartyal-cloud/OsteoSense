"""
JointSaathi AI Microservice — FastAPI
Rule-based OA risk predictor (same algorithm mirrored in aiService.js fallback).
Runs on port 8000 independently from the Express backend.
"""

from fastapi import FastAPI
from pydantic import BaseModel, Field
from typing import Optional, List
import json
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("jointsaathi-ai")

app = FastAPI(
    title="JointSaathi AI Service",
    description="Rule-based OA risk prediction microservice for JointSaathi",
    version="1.0.0",
)


class ScreeningInput(BaseModel):
    pain_level: int = Field(..., ge=0, le=10, description="Pain level 0-10")
    stiffness_duration: str = Field(
        "none",
        description="One of: none, <30, 30-60, >60",
    )
    swelling: bool = Field(False, description="Joint swelling observed")
    past_injury: bool = Field(False, description="History of joint injury")
    gait_data: Optional[str] = Field(None, description="JSON string of gait sensor data")


class PredictionResult(BaseModel):
    risk_level: str
    confidence: float
    contributing_factors: List[str]
    reasoning: str
    model_version: str = "rule_based_v1.0"


def rule_based_predict(data: ScreeningInput) -> PredictionResult:
    """
    Rule-based OA risk scoring.
    This exact algorithm is also mirrored in the Express aiService.js fallback
    and the on-device TFLiteService to ensure consistency.

    Scoring:
      Pain Level: 0-10
        ≥7 → +3 (severe)
        4-6 → +2 (moderate)
        2-3 → +1 (mild)
      Stiffness Duration:
        >60 min → +2
        30-60 min → +1
      Swelling → +2
      Past Injury → +1
      Gait Irregularity (variance):
        >0.7 → +2
        >0.4 → +1

    Max possible: 10
    High: ≥6, Medium: 3-5, Low: 0-2
    """
    risk_score = 0
    factors = []

    # Pain level
    if data.pain_level >= 7:
        risk_score += 3
        factors.append("Severe pain level (≥7/10)")
    elif data.pain_level >= 4:
        risk_score += 2
        factors.append("Moderate pain level (4–6/10)")
    elif data.pain_level >= 2:
        risk_score += 1
        factors.append("Mild pain level (2–3/10)")

    # Stiffness duration
    if data.stiffness_duration == ">60":
        risk_score += 2
        factors.append("Prolonged morning stiffness (>60 minutes)")
    elif data.stiffness_duration == "30-60":
        risk_score += 1
        factors.append("Moderate morning stiffness (30–60 minutes)")

    # Swelling
    if data.swelling:
        risk_score += 2
        factors.append("Joint swelling observed")

    # Past injury
    if data.past_injury:
        risk_score += 1
        factors.append("History of joint injury")

    # Gait irregularity
    if data.gait_data:
        try:
            parsed = json.loads(data.gait_data)
            variance = parsed.get("variance", 0)
            if variance > 0.7:
                risk_score += 2
                factors.append("Significant gait irregularity detected")
            elif variance > 0.4:
                risk_score += 1
                factors.append("Mild gait irregularity detected")
        except (json.JSONDecodeError, AttributeError):
            pass

    # Risk level + confidence
    if risk_score >= 6:
        risk_level = "high"
        confidence = min(0.65 + (risk_score - 6) * 0.05, 0.92)
        reasoning = (
            "Multiple significant risk factors detected. "
            "Clinical evaluation recommended urgently."
        )
    elif risk_score >= 3:
        risk_level = "medium"
        confidence = min(0.55 + (risk_score - 3) * 0.04, 0.72)
        reasoning = (
            "Moderate risk factors present. "
            "Lifestyle modifications and follow-up recommended."
        )
    else:
        risk_level = "low"
        confidence = min(0.70 + (3 - risk_score) * 0.06, 0.88)
        reasoning = (
            "Risk factors are minimal. "
            "Encourage preventive measures and regular monitoring."
        )

    if not factors:
        factors = ["No significant risk factors detected"]

    return PredictionResult(
        risk_level=risk_level,
        confidence=round(confidence, 3),
        contributing_factors=factors,
        reasoning=reasoning,
    )


@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "service": "JointSaathi AI Microservice",
        "version": "1.0.0",
    }


@app.post("/predict", response_model=PredictionResult)
def predict(input_data: ScreeningInput):
    """
    Predict OA risk level from symptom + gait data.
    Returns risk_level (low/medium/high), confidence (0-1),
    contributing_factors (list of strings), and reasoning.
    """
    logger.info(
        f"Prediction request: pain={input_data.pain_level}, "
        f"stiffness={input_data.stiffness_duration}, "
        f"swelling={input_data.swelling}, "
        f"past_injury={input_data.past_injury}"
    )

    result = rule_based_predict(input_data)
    logger.info(f"Prediction result: {result.risk_level} (confidence={result.confidence})")
    return result


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
