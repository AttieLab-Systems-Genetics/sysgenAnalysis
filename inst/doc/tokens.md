# Monitoring Gemini and Antigravity Tokens

This document summarizes tools and methods for monitoring token usage in Gemini and the Antigravity IDE.

## Gemini Token Monitoring

To track your API usage and token counts, use the following native Google tools:

### 1. Google AI Studio

- **Usage Statistics**: Go to [aistudio.google.com](https://aistudio.google.com/), click on "Get API key" (left sidebar), and select "View usage data".
- **Real-time Count**: The prompt editor displays a token count in the bottom-right corner as you type.

### 2. Google Cloud Console

- **Generative Language API**: Search for "Generative Language API" in the Google Cloud Console to see detailed request summaries.
- **Billing Reports**: Check the "Billing" section for costs associated with token consumption.

### 3. API Response Metadata

- Every Gemini API response includes a `usageMetadata` object:

  ```json
  "usageMetadata": {
    "promptTokenCount": 123,
    "candidatesTokenCount": 456,
    "totalTokenCount": 579
  }
  ```

---

## Antigravity Activity Monitoring

While Antigravity uses Gemini tokens internally, you can monitor its activity through its built-in transparency features:

### 1. Agent Manager

- Track multiple agents working in parallel.
- View real-time logs of agent "thinking" and tool usage.

### 2. Artifacts

- **Implementation Plans**: Review the logic before the agent writes code.
- **Walkthroughs**: Verify results and consumed context after tasks complete.
- **Recordings**: Watch browser-based tasks to see exactly how agents interact with sites.

---

## Third-Party Monitoring Tools

For more advanced needs (e.g., team-wide usage or optimization), consider these tools:

- **Humanloop**: Developer-focused LLMOps platform for observability.
- **Vantage**: Consolidated cloud cost visibility for Gemini across AI Studio and Vertex AI.
- **Helicone**: An open-source observability platform for generative AI.

---

## Token Reference

- **~100 Tokens** = 60-80 English words.
- **1 Token** ≈ 4 characters of English text.
