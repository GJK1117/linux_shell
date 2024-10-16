#!/bin/bash

# Install necessary packages
yum install -y net-tools bind-utils bind

# Start and enable the named service
systemctl start named
systemctl enable named

# Verify installation
yum info bind

# Backup the original named.conf file before modifying it
cp /etc/named.conf /etc/named.conf.bak

# Modify specific lines in named.conf (listen-on, listen-on-v6, allow-query)
sed -i 's/listen-on port 53 { .*/listen-on port 53 { any; };/' /etc/named.conf
sed -i 's/listen-on-v6 port 53 { .*/listen-on-v6 port 53 { none; };/' /etc/named.conf
sed -i 's/allow-query     { .*/allow-query     { any; };/' /etc/named.conf

# Check if zone configurations already exist, if not, append them
if ! grep -q 'zone "example.com"' /etc/named.conf; then
cat <<EOL >> /etc/named.conf

zone "example.com" IN {
        type master ;
        file "data/example.com.zone";
};

zone "138.168.192.in-addr.arpa" IN {
        type master ;
        file "data/db.192.168.138";
};
EOL
fi

# Create forward zone file
cat <<EOL > /var/named/data/example.com.zone
\$TTL 3H
@       IN SOA  server.example.com. root.example.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        IN      NS      server.example.com.
        IN      MX  10  mail.example.com.
        IN      A       192.168.138.100
www     IN      A       192.168.138.101
db      IN      A       192.168.138.102
client  IN      A       192.168.138.103
server  IN      A       192.168.138.100
EOL

# Create reverse zone file
cat <<EOL > /var/named/data/db.192.168.138
\$TTL 3H
@       IN SOA  server.example.com. root.example.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        IN      NS      server.server.example.com.
101     IN      PTR     www.example.com.
102     IN      PTR     db.example.com.
103     IN      PTR     client.example.com.
EOL

# Set permissions for zone files
chown root:named /var/named/data/example.com.zone
chown root:named /var/named/data/db.192.168.138

# Check zone files for correctness
named-checkzone example.com /var/named/data/example.com.zone
named-checkzone 138.168.192.in-addr.arpa /var/named/data/db.192.168.138

# Check the named configuration
named-checkconf /etc/named.conf

# Restart named service to apply changes
systemctl restart named

# Configure firewall
firewall-cmd --add-service=dns --permanent
firewall-cmd --reload
firewall-cmd --list-all

echo "DNS Server setup completed successfully."
