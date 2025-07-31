#!/bin/bash

# Update the system
apt update -y

# Install nginx
apt install -y nginx

# Start and enable nginx service
systemctl start nginx
systemctl enable nginx

# Create a custom HTML page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Hello World - AWS Migration Lab</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            background-color: #f0f0f0;
            padding: 50px;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            max-width: 600px;
            margin: 0 auto;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
        }
        .info {
            color: #666;
            margin-top: 20px;
        }
        .aws-logo {
            color: #ff9900;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Hello World from AWS EC2!</h1>
        <p>This is a simple web server running on Amazon EC2 instance.</p>
        <p class="aws-logo">AWS Migration Lab</p>
        <div class="info">
            <p>Server: Ubuntu</p>
            <p>Web Server: Nginx</p>
            <p>Instance launched: $(date)</p>
        </div>
    </div>
</body>
</html>
EOF

# Set proper permissions
chmod 644 /var/www/html/index.html

# Ensure nginx is serving the correct directory
systemctl restart nginx

# Create a simple status page
cat > /var/www/html/status.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Server Status</title>
</head>
<body>
    <h1>Server Status</h1>
    <p>Nginx is running successfully!</p>
    <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
    <p>Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</p>
</body>
</html>
EOF

# Log the completion
echo "User data script completed successfully at $(date)" >> /var/log/user-data.log