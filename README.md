# SlackQL 🚀

Transform plain-English questions into Snowflake-ready SQL right inside Slack—no more context-switching, no more guess-and-check queries. Built during **AI Week**, a 3½-day hackathon at **Fetch Rewards**.

---

## ✨ What You’ll Find Here

| Path | Description |
|------|-------------|
| `slackql_demo.json` | n8n workflow that glues Slack → Pinecone → LLM → Snowflake and back. Import this into your own n8n instance. |
| `seed_data/` | SQL scripts that generate dummy Snowflake data so you can test end-to-end without prod access. |

---

## 🔍 How SlackQL Works

1. **Ask in plain English**  
   “What were our total sales last quarter by region?” → posted in Slack.

2. **Semantic Search (RAG)**  
   Schema docs are embedded in a **Pinecone** vector DB; we fetch only the tables/columns that matter.

3. **LLM-based SQL Generator**  
   A large-language model drafts Snowflake SQL using the retrieved metadata.

4. **SQL Enhancer**  
   A secondary agent lint-checks syntax and logic, tightening up edge cases.

5. **Execute in Snowflake**  
   The validated query runs on your warehouse.

6. **Results in Slack**  
   SlackQL posts the final SQL _and_ a neatly formatted result table back to the thread.

All orchestration lives in **n8n**, a low-code automations platform that keeps each service talking to the next.

---

## 🛠️ Quick Start

> **Prerequisites**  
> • Slack workspace & bot token  
> • Snowflake account + credentials  
> • Pinecone API key  
> • n8n (self-hosted or cloud)

## 🎥 Demo Video

<video controls width="640">
  <source src="SlackQL_demo_video.mp4" type="video/mp4">
  Sorry, your browser doesn’t support embedded videos.  
  You can watch it on <a href="https://www.linkedin.com/posts/your-post-id-here">LinkedIn</a>.
</video>

