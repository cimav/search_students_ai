class SessionsController < ApplicationController

  def create
    auth = request.env['omniauth.auth']
    email = auth['info']['email']
    name  = auth['info']['name']
    image = auth['info']['image'] # 👈 foto de perfil
    provider = auth['provider']


    ip = request.remote_ip
    time = Time.current.strftime("%Y-%m-%d %H:%M:%S")

    # Verifica dominio permitido
    valid_domains = ["@cimav.edu.mx"]

    unless valid_domains.any? { |d| email.downcase.ends_with?(d) }
      Rails.logger.warn "[#{time}] LOGIN BLOQUEADO | Email: #{email} | Nombre: #{name} | IP: #{ip} | Proveedor: #{provider} | Motivo: Dominio no permitido"
      redirect_to login_path, alert: "Solo se permite acceso con cuentas @cimav.edu.mx"
      return
    end

    # Verifica en la base de datos
    user = User.find_by(email: email, status: 1)

    puts "#{email} | #{name} | #{user.id}"


    if user
      session[:user_id] = user.id
      session[:user_name] = name
      session[:user_image] = image
      # Rails.logger.info "[#{time}] LOGIN EXITOSO | Usuario: #{email} (#{user.name}) | IP: #{ip} | Proveedor: #{provider}"
      redirect_to root_path, notice: "Bienvenido #{name}"
    else
      Rails.logger.warn "[#{time}] LOGIN BLOQUEADO | Email: #{email} | Nombre: #{name} | IP: #{ip} | Motivo: Usuario no registrado o inactivo"
      redirect_to login_path, alert: "Acceso denegado: usuario no autorizado"
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Sesión cerrada correctamente"
  end

end

