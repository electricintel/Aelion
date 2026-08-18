# Universal Sentence Protocol (USP)

USP is the communication backbone of AELION.

## Sentence Structure
A USP sentence contains:
- id
- timestamp
- source
- target_engine
- intent
- payload
- confidence
- tags

## Routing
USP sentences are routed through:
- governance (pre-check)
- message bus
- engine handlers
- governance (post-check)
- HUD or API response

USP ensures all communication is normalized, traceable, and auditable.
