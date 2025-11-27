from typing import Any

from aws_lambda_typing.context import Context
import numpy as np


def handler(event: dict[str, Any], context: Context) -> dict[str, Any]:
    matrix = np.array(event["matrix"], dtype=float)
    inv = np.linalg.inv(matrix)
    return {"inverse": inv.tolist()}
