
pipeline:

  build_test_image:
    image: docker/compose:1.22.0
    privileged: true
    commands:
      - docker build -t {{ project_name }}:${DRONE_COMMIT:0:8} .
      - docker tag {{ project_name }}:${DRONE_COMMIT:0:8} {{ project_name }}:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    when:
      branch: [ develop, master ]
      event: [ push, pull_request ]

  test:
    group: test
    image: "{{ project_name }}:${DRONE_COMMIT:0:8}"
    secrets:
      - secret_key
      - database_url
    commands:
      - sleep 10
      - python manage.py check --deploy --settings={{ project_name }}.settings --fail-level ERROR
      - python manage.py test -v 2
    when:
      branch: [ develop, master ]
      event: [ push, pull_request ]


  #############################################
  #             Develop Staging               #
  #############################################

  build-devel:
    image: plugins/ecr
    repo: {{ staging_repo_url }}/{{ project_name }}
    registry: {{ staging_repo_url }}
    access_key: ${aws_access_key_id}
    secret_key: ${aws_secret_access_key}
    tags:
      - latest
      - ${DRONE_COMMIT:0:8}
    region: {{ staging_region }}
    dockerfile: Dockerfile.production
    context: .
    secrets:
      - aws_access_key_id
      - aws_secret_access_key
    storage_driver: overlay2
    when:
      branch: develop
      event: push

  login_with_ecr_devel:
    group: login-develop
    image: appleboy/drone-ssh
    host:
      {% for ip_instance in staging_ip_instances %}
      - {{ ip_instance }}
      {% endfor %}
    port: 22
    command_timeout: 360
    secrets:
      - source: ssh_username
        target: ssh_username
      - source: ssh_key_develop
        target: ssh_key
    script:
      - eval $(aws ecr get-login --no-include-email)
    when:
      branch: develop
      event: push

  deploy_web_develop:
    group: deploy-service-develop
    image: appleboy/drone-ssh
    host: {{ staging_ip_instances.0 }}
    port: 22
    command_timeout: 360
    secrets:
      - source: ssh_username
        target: ssh_username
      - source: ssh_key_develop
        target: ssh_key
    script:
      - >
        docker service update --force
        --with-registry-auth
        --update-order start-first
        --update-parallelism 1
        --restart-condition on-failure
        --restart-max-attempts 2
        --update-failure-action rollback
        --image {{ staging_repo_url }}/{{ project_name }}:${DRONE_COMMIT:0:8}
        {{project_name}}_web
    when:
      branch: develop
      event: push


  deploy_worker_develop:
    group: deploy-service-develop
    image: appleboy/drone-ssh
    host: {{ staging_ip_instances.0 }}
    port: 22
    command_timeout: 360
    secrets:
      - source: ssh_username
        target: ssh_username
      - source: ssh_key_develop
        target: ssh_key
    script:
      - >
        docker service update --force
        --with-registry-auth
        --update-order start-first
        --update-parallelism 1
        --restart-condition on-failure
        --restart-max-attempts 2
        --update-failure-action rollback
        --image {{ staging_repo_url }}/{{ project_name }}:${DRONE_COMMIT:0:8}
        {{project_name}}_worker
    when:
      branch: develop
      event: push


  deploy_beat_develop:
    group: deploy-service-develop
    image: appleboy/drone-ssh
    host: {{ staging_ip_instances.0 }}
    port: 22
    command_timeout: 360
    secrets:
      - source: ssh_username
        target: ssh_username
      - source: ssh_key_develop
        target: ssh_key
    script:
      - >
        docker service update --force
        --with-registry-auth
        --update-order stop-first
        --update-parallelism 1
        --restart-condition on-failure
        --restart-max-attempts 2
        --update-failure-action rollback
        --image {{ staging_repo_url }}/{{ project_name }}:${DRONE_COMMIT:0:8}
        {{ project_name }}_beat
    when:
      branch: develop
      event: push


  deploy_flower_develop:
    group: post-deploy-develop
    image: appleboy/drone-ssh
    host: {{ staging_ip_instances.0 }}
    port: 22
    command_timeout: 360
    secrets:
      - source: ssh_username
        target: ssh_username
      - source: ssh_key_develop
        target: ssh_key
    script:
      - >
        docker service update --force
        --with-registry-auth
        --update-order stop-first
        --update-parallelism 1
        --restart-condition on-failure
        --restart-max-attempts 2
        --update-failure-action rollback
        --image {{ staging_repo_url }}/{{ project_name }}:${DRONE_COMMIT:0:8}
        {{ project_name }}_flower
    when:
      branch: develop
      event: push

  collectstatic_develop:
    group: post-deploy-develop
    image: appleboy/drone-ssh
    host:
      {% for ip_instance in staging_ip_instances %}
      - {{ ip_instance }}
      {% endfor %}
    command_timeout: 360
    secrets:
      - source: ssh_username
        target: ssh_username
      - source: ssh_key_develop
        target: ssh_key
    script:
      - container=$(docker ps -q --filter name={{ project_name }}_web.1)
      - if [[ ! -z "$container" ]]; then container=$(echo $container | awk '{print $1}') && docker exec $container python manage.py collectstatic --noinput; fi
    when:
      branch: develop
      event: push

  prune_develop:
    group: post-deploy-develop
    image: appleboy/drone-ssh
    host:
      {% for ip_instance in staging_ip_instances %}
      - {{ ip_instance }}
      {% endfor %}
    command_timeout: 360
    secrets:
      - source: ssh_username
        target: ssh_username
      - source: ssh_key_develop
        target: ssh_key
    script:
      - docker container prune -f
    when:
      branch: develop
      event: push


  #############################################
  #             Master Production             #
  #############################################

  build:
    image: plugins/ecr
    repo: {{ production_repo_url }}/{{ project_name }}
    registry: {{ production_repo_url }}
    access_key: ${aws_access_key_id}
    secret_key: ${aws_secret_access_key}
    tags:
      - latest
      - ${DRONE_COMMIT:0:8}
    region: {{ production_region }}
    dockerfile: Dockerfile.production
    context: .
    secrets:
      - aws_access_key_id
      - aws_secret_access_key
    storage_driver: overlay2
    when:
      branch: master
      event: push


  login_with_ecr:
    group: login
    image: appleboy/drone-ssh
    host:
      {% for ip_instance in production_ip_instances %}
      - {{ ip_instance }}
      {% endfor %}
    port: 22
    command_timeout: 360
    secrets:
      - ssh_username
      - ssh_key
    script:
      - eval $(aws ecr get-login --no-include-email)
    when:
      branch: [ master ]
      event: push

  deploy_web:
    group: deploy-service
    image: appleboy/drone-ssh
    host: {{ production_ip_instances.0 }}
    port: 22
    command_timeout: 3600
    secrets:
      - ssh_username
      - ssh_key
    script:
      - >
        docker service update
        --with-registry-auth
        --update-order start-first
        --update-parallelism 1
        --update-delay 30s
        --stop-grace-period 40s
        --restart-condition on-failure
        --restart-max-attempts 2
        --update-failure-action rollback
        --image {{ production_repo_url }}/{{ project_name }}:${DRONE_COMMIT:0:8}
        --env-add DRONE_COMMIT_SHORT=${DRONE_COMMIT:0:8}
        {{ project_name }}_web
    when:
      branch: [ master ]
      event: push


  deploy_worker:
    group: deploy-service
    image: appleboy/drone-ssh
    host: {{ production_ip_instances.0 }}
    port: 22
    command_timeout: 3600
    secrets:
      - ssh_username
      - ssh_key
    script:
      - >
        docker service update
        --with-registry-auth
        --update-order start-first
        --update-parallelism 1
        --update-delay 30s
        --stop-grace-period 40s
        --restart-condition on-failure
        --restart-max-attempts 2
        --update-failure-action rollback
        --image {{ production_repo_url }}/{{ project_name }}:${DRONE_COMMIT:0:8}
        --env-add DRONE_COMMIT_SHORT=${DRONE_COMMIT:0:8}
        {{ project_name }}_worker
    when:
      branch: [ master ]
      event: push


  deploy_beat:
    group: deploy-service
    image: appleboy/drone-ssh
    host: {{ production_ip_instances.0 }}
    port: 22
    command_timeout: 3600
    secrets:
      - ssh_username
      - ssh_key
    script:
      - >
        docker service update
        --with-registry-auth
        --update-order stop-first
        --update-parallelism 1
        --update-delay 30s
        --stop-grace-period 40s
        --restart-condition on-failure
        --restart-max-attempts 2
        --update-failure-action rollback
        --image {{ production_repo_url }}/{{ project_name }}:${DRONE_COMMIT:0:8}
        --env-add DRONE_COMMIT_SHORT=${DRONE_COMMIT:0:8}
        {{ project_name }}_beat
    when:
      branch: [ master ]
      event: push

  deploy_flower:
    group: post-deploy
    image: appleboy/drone-ssh
    host: {{ production_ip_instances.0 }}
    port: 22
    command_timeout: 3600
    secrets:
      - ssh_username
      - ssh_key
    script:
      - >
        docker service update
        --with-registry-auth
        --update-order stop-first
        --update-parallelism 1
        --update-delay 30s
        --stop-grace-period 40s
        --restart-condition on-failure
        --restart-max-attempts 2
        --update-failure-action rollback
        --image {{ production_repo_url }}/{{ project_name }}:${DRONE_COMMIT:0:8}
        --env-add DRONE_COMMIT_SHORT=${DRONE_COMMIT:0:8}
        {{ project_name }}_flower
    when:
      branch: [ master ]
      event: push

  collectstatic:
    group: post-deploy
    image: appleboy/drone-ssh
    host:
      {% for ip_instance in production_ip_instances %}
      - {{ ip_instance }}
      {% endfor %}
    command_timeout: 360
    secrets:
      - ssh_username
      - ssh_key
    script:
      - container=$(docker ps -q --filter name={{ project_name }}_web.2)
      - if [[ ! -z "$container" ]]; then container=$(echo $container | awk '{print $1}') && docker exec $container python manage.py collectstatic --noinput; fi
    when:
      branch: [ master ]
      event: push

  prune:
    group: post-deploy
    image: appleboy/drone-ssh
    host:
      {% for ip_instance in production_ip_instances %}
      - {{ ip_instance }}
      {% endfor %}
    command_timeout: 360
    secrets:
      - ssh_username
      - ssh_key
    script:
      - docker container prune -f
    when:
      branch: [ master ]
      event: push


  ######################################################
  # Docker Stack deploy for all thor services develop  #
  ######################################################

  scp-environment-develop:
    image: appleboy/drone-scp
    host: {{ staging_ip_instances.0 }}
    port: 22
    secrets:
      - source: ssh_username
        target: ssh_username
      - source: ssh_key_develop
        target: ssh_key
    target: $HOME/{{ project_name }}/
    source: swarm/{{ project_name }}.yml
    strip_components: 1
    when:
      branch: develop
      event: deployment
      environment: staging

  stack-deploy-swarm-develop:
    image: appleboy/drone-ssh
    host: {{ staging_ip_instances.0 }}
    port: 22
    command_timeout: 3600
    secrets:
      - source: ssh_username
        target: ssh_username
      - source: ssh_key_devel
        target: ssh_key
    script:
      - eval $(aws ecr get-login --no-include-email)
      - BUILD_TAG=${DRONE_COMMIT:0:8} docker stack deploy -c $HOME/{{ project_name }}/{{ project_name }}.yml {{ project_name }} --with-registry-auth
    when:
      branch: develop
      event: deployment
      environment: staging

  #############################################
  # Docker Stack deploy End                   #
  #############################################

  ####################################################
  # Docker Stack deploy for all thor services master #
  ####################################################

  scp-environment:
    image: appleboy/drone-scp
    host: {{ production_ip_instances.0 }}
    port: 22
    secrets:
      - ssh_username
      - ssh_key
    target: $HOME/{{ project_name }}/
    source: swarm/{{ project_name }}.yml
    strip_components: 1
    when:
      branch: [ master ]
      event: deployment
      environment: production

  stack-deploy-swarm:
    image: appleboy/drone-ssh
    host: {{ production_ip_instances.0 }}
    port: 22
    command_timeout: 360
    secrets:
      - ssh_username
      - ssh_key
    script:
      - eval $(aws ecr get-login --no-include-email)
      - BUILD_TAG=${DRONE_COMMIT:0:8} docker stack deploy -c $HOME/{{ project_name }}/{{ project_name }}.yml {{ project_name }} --with-registry-auth
    when:
      branch: [ master ]
      event: deployment
      environment: production

  #############################################
  # Docker Stack deploy End                   #
  #############################################

  {% raw %}
  slack:
    image: plugins/slack
    secrets:
      - slack_webhook
    webhook: ${SLACK_WEBHOOK}
    channel: ci-messages
    username: drone
    template: >
      {{#success build.status}}
        *{{build.status}}* {{repo.name}} <{{build.link}}|{{build.number}}>. Build Success
        Author: {{build.author}}
        Commit: <${DRONE_COMMIT_LINK}|{{repo.owner}}/{{repo.name}}#${DRONE_COMMIT:0:8}> `${DRONE_COMMIT_MESSAGE}`
        Trigger event: {{build.event}} ({{build.branch}})
      {{else}}
        *{{build.status}}* {{repo.name}} <{{build.link}}|{{build.number}}>. Build Failure
        Author: {{build.author}}
        Commit: <${DRONE_COMMIT_LINK}|{{repo.owner}}/{{repo.name}}#${DRONE_COMMIT:0:8}> `${DRONE_COMMIT_MESSAGE}`
        Trigger event: {{build.event}} ({{build.branch}})
      {{/success}}
    when:
      status: [ success, failure ]
    {% endraw %}

services:

  postgres:
    image: postgres:10
    secrets:
      - postgres_user
      - postgres_password
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=postgres

branches: [ develop, master ]
