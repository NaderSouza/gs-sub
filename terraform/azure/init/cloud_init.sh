# Criação do arquivo cloud_init.sh
resource "local_file" "cloud_init" {
  filename = "${path.module}/cloud_init.sh"
  content  = <<-EOT
#!/bin/bash
echo "Hello, this is cloud-init script!" > /tmp/cloud_init_output.txt
# Adicione seus comandos ou configurações aqui
EOT
}

# Recurso de dados template para codificar o script em base64
data "template_file" "cloud_init" {
  template = local_file.cloud_init.content
}

# Recurso Azure VM
resource "azurerm_virtual_machine" "web_instance" {
  # ... (outras configurações para VM)

  os_profile {
    custom_data = base64encode(data.template_file.cloud_init.rendered)
  }

  # ... (outras configurações para VM)
}
