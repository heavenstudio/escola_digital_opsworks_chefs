server {
  listen   80;
  server_name  <%= @application[:domains].join(" ") %> <%= node[:hostname] %>;
  access_log  <%= node[:nginx][:log_dir] %>/<%= @application[:domains].first %>.access.log;

  location / {
    root   <%= @application[:absolute_document_root] %>;
    index  index.html index.htm index.php;
  }

  location /formacao/ {
    proxy_pass http://54.83.37.144/formacao/;
    proxy_redirect default;
  }

  # Block all svn access
  if ($request_uri ~* ^.*\.svn.*$) {
     return 404;
  }

  # Block all git access
  if ($request_uri ~* ^.*\.git.*$) {
     return 404;
  }

  location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
  }

}

<% if @application[:ssl_support] %>
server {
  listen   443;
  server_name  <%= @application[:domains].join(" ") %> <%= node[:hostname] %>;
  access_log  <%= node[:nginx][:log_dir] %>/<%= @application[:domains].first %>-ssl.access.log;

  ssl on;
  ssl_certificate <%= node[:nginx][:dir] %>/ssl/<%= @application[:domains].first %>.crt;
  ssl_certificate_key <%= node[:nginx][:dir] %>/ssl/<%= @application[:domains].first %>.key;
  <% if @application[:ssl_certificate_ca] -%>
  ssl_client_certificate <%= node[:nginx][:dir] %>/ssl/<%= @application[:domains].first %>.ca;
  <% end -%>

  location / {
    root   <%= @application[:absolute_document_root] %>;
    index  index.html index.htm index.php;
  }

  # Block all svn access
  if ($request_uri ~* ^.*\.svn.*$) {
     return 404;
  }

  # Block all git access
  if ($request_uri ~* ^.*\.git.*$) {
     return 404;
  }
}
<% end %>
