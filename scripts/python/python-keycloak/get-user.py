from keycloak import KeycloakAdmin
from keycloak import KeycloakOpenIDConnection

keycloak_connection = KeycloakOpenIDConnection(
    server_url="http://nuc-linux-build:28080/",
    username='keycloak',
    password='Password1!',
    realm_name="RiskIntegrity",
    user_realm_name="only_if_other_realm_than_master",
    client_id="my_client",
    client_secret_key="b593d175-611d-40a8-a470-7d64d53e1b5c",
    verify=True)

keycloak_admin = KeycloakAdmin(connection=keycloak_connection)
users = keycloak_admin.get_users({})