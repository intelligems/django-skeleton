from rest_framework import serializers
from ..models import Account


class UserSerializer(serializers.ModelSerializer):
    """
    User accounts serializer
    """

    class Meta:
        model = Account
        fields = (
            'id', 'username', 'email', 'first_name', 'last_name',
            'is_active', 'is_staff', 'is_superuser', 'date_joined'
        )
        read_only_fields = (
            'username', 'auth_token', 'date_joined'
        )


class PasswordSerializer(serializers.Serializer):
    """
    Serializer for password change endpoint.
    """
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)
