#!/bin/bash
apt-get update -y
apt-get install -y apache2

systemctl start apache2
systemctl enable apache2

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Blue Deployment</title>
</head>
<body style="background-color: #3498db; color: white; text-align: center; font-family: sans-serif; padding-top: 50px;">
    <h1>Welcome to the Blue Deployment</h1>
</body>
</html>
EOF
