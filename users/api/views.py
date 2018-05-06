from rest_framework import viewsets, mixins, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .serializers import UserSerializer, PasswordSerializer
from ..models import Account


class UserViewSet(mixins.ListModelMixin,
                  mixins.RetrieveModelMixin,
                  mixins.UpdateModelMixin,
                  viewsets.GenericViewSet):
    """
    list:
    Return a list of all the existing users.
    read:
    Return the given user.
    me:
    Return authenticated user.
    """
    queryset = Account.objects.all()
    serializer_class = UserSerializer

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def me(self, request, *args, **kwargs):
        return Response(self.serializer_class(instance=self.get_object()).data)

    @action(detail=False, methods=['put'], serializer_class=PasswordSerializer)
    def set_password(self, request):
        serializer = PasswordSerializer(data=request.data)
        user = self.get_object()

        if serializer.is_valid():
            if not user.check_password(serializer.data.get('old_password')):
                return Response(
                    {
                        'old_password': ['Wrong password.']
                    },
                    status=status.HTTP_400_BAD_REQUEST
                )
            user.set_password(serializer.data.get('new_password'))
            user.save()

            return Response({'status': 'password set'}, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
