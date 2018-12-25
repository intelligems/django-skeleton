from uuid import uuid4
from django.db import models


class TimestampedAbstractModel(models.Model):
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class BaseModel(TimestampedAbstractModel):
    id = models.UUIDField(
        default=uuid4,
        primary_key=True
    )

    class Meta:
        abstract = True
        ordering = ['-created']
