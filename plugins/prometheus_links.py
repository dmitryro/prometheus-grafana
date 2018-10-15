from airflow.plugins_manager import AirflowPlugin
from flask_admin.base import MenuLink

metrics = MenuLink(
    category='Prometheus',
    name='Metrics',
    url='http://0.0.0.0:9090/metrics')


graph = MenuLink(
    category='Prometheus',
    name='Graph',
    url='http://0.0.0.0:9090/graph')


# Defining the plugin class
class PrometheusLinksPlugin(AirflowPlugin):
    name = "PrometheusLinks"
    operators = []
    flask_blueprints = []
    hooks = []
    executors = []
    admin_views = []
    menu_links = [metrics, graph]

