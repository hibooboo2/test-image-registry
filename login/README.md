#Manage Htpasswd server.

Simple node app that will allow a user account signup system for nginx.
Add a proxy to the app in an nginx conf. The app allows signup and change password


Simply works by modifying the htpasswd file used by ngnix, will only be touched if
user is authed. Currently there is no support for different roles. Everyone is a super admin.
