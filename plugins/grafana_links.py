from airflow.plugins_manager import AirflowPlugin
from flask_admin.base import MenuLink

grafana = MenuLink(    
    category='Grafana',
    name='Dashboard',
    url='http://0.0.0.0:3000')


# Defining the plugin class
class GrafanaLinksPlugin(AirflowPlugin):
    name = "GrafanaLinks"
    operators = []
    flask_blueprints = []
    hooks = []
    executors = []
    admin_views = []
    menu_links = [grafana]

