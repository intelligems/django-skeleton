release: python manage.py migrate --no-input
web: gunicorn {{ project_name }}.wsgi --log-file -
worker: celery -A {{ project_name }} worker -l info