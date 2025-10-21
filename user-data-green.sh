#!/bin/bash
apt-get update -y
apt-get install -y apache2

systemctl start apache2
systemctl enable apache2

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Green Deployment</title>
</head>
<body style="background-color: #2ecc71; color: white; text-align: center; font-family: sans-serif; padding-top: 50px;">
    <h1>Welcome to the Green Deployment</h1>
</body>
</html>
EOF
