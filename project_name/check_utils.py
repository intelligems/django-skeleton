from pyrsistent import pmap


def get_settings(settings):
    settings_list = list(
        filter(lambda x: not str(x).startswith('_') and x != 'is_overridden', dir(settings))
    )
    configured_values = [getattr(settings, value) for value in settings_list]
    return dict(zip(settings_list, configured_values))


def expected_settings(settings):
    template = pmap(initial=get_settings(settings))
    develop = pmap(initial={
                'SWARM_MODE': False,
                'DEBUG': True,
                'ENVIRONMENT_CHECKS': 'develop'
            }
        )
    staging = pmap(initial={
                'SWARM_MODE': True,
                'DEBUG': False,
                'ENVIRONMENT_CHECKS': 'staging',
            }
        )
    production = pmap(initial={
                'SWARM_MODE': True,
                'DEBUG': False,
                'ENVIRONMENT_CHECKS': 'production',
            }
        )

    from collections import namedtuple
    ExpectedValues = namedtuple(
        'ExpectedValues',
        [
            'current',
            'develop',
            'staging',
            'production'
        ]
    )
    return ExpectedValues(
        current=template,
        develop=develop,
        staging=staging,
        production=production
    )
