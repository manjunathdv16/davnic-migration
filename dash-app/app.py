"""
Domino Data Lab - Demo Dash App
--------------------------------
A minimal Plotly Dash application used to validate that a Domino
Workspace / App deployment pipeline is working end to end.

Domino Apps expect the process to listen on 0.0.0.0:8888.
"""

import os
import pandas as pd
import plotly.express as px
from dash import Dash, dcc, html, Input, Output

# --- Sample data -----------------------------------------------------------
df = pd.DataFrame({
    "Category": ["Compute", "Storage", "Model Registry", "Flows", "Apps"],
    "Usage": [42, 18, 27, 12, 35],
})

# --- App ---------------------------------------------------------------
# Domino-specific routing: DOMINO_RUN_HOST_PATH is injected at runtime
# with the proxy path the App is actually served behind (e.g. /apps/<id>/)
runurl = os.environ.get("DOMINO_RUN_HOST_PATH", "/")

app = Dash(
    __name__,
    routes_pathname_prefix="/",
    requests_pathname_prefix=runurl,
)
server = app.server  # exposed for gunicorn, if you switch to it later

app.layout = html.Div(
    style={"fontFamily": "Arial, sans-serif", "margin": "40px"},
    children=[
        html.H1("Domino Platform Demo App"),
        html.P(
            "This app is running inside a Domino Workspace / App. "
            "Use it to confirm your environment, port, and app.sh setup work."
        ),
        dcc.Dropdown(
            id="category-filter",
            options=[{"label": c, "value": c} for c in df["Category"]],
            value=list(df["Category"]),
            multi=True,
        ),
        dcc.Graph(id="usage-graph"),
        html.Div(
            id="env-info",
            style={"marginTop": "30px", "fontSize": "12px", "color": "#666"},
        ),
    ],
)


@app.callback(Output("usage-graph", "figure"), Input("category-filter", "value"))
def update_graph(selected_categories):
    filtered = df[df["Category"].isin(selected_categories)]
    fig = px.bar(filtered, x="Category", y="Usage", title="Sample Domino Resource Usage")
    return fig


@app.callback(Output("env-info", "children"), Input("category-filter", "value"))
def show_env_info(_):
    project = os.environ.get("DOMINO_PROJECT_NAME", "N/A")
    run_id = os.environ.get("DOMINO_RUN_ID", "N/A")
    user = os.environ.get("DOMINO_STARTING_USERNAME", "N/A")
    return f"Domino Project: {project} | Run ID: {run_id} | User: {user}"


if __name__ == "__main__":
    # Domino Apps route external traffic to port 8888 on 0.0.0.0
    app.run(host="0.0.0.0", port=8888, debug=False)
