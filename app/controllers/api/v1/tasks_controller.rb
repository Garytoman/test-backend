class Api::V1::TasksController < ApplicationController
  # Tanto el usuario como la clave, en una aplicación real, se deberían almacenar 
  # en variables de entorno o cualquier otro tipo de almacenamiento secreto,
  # asegurándonos de que no se suben al repositorio. Además se debería utilizar 
  # una conexión segura ya que los datos de acceso son visibles en la llamada.
  # En este caso de ejemplo se muestran para facilitar las pruebas de la API.
  
  http_basic_authenticate_with name: "admin", password: "secret"

  def all 
    resp = []

    if params[:time_status].present?
      tasks = Task.send(params[:time_status])
    else
      tasks = Task.all
    end

    tasks.each do |task|
      resp << JSON.parse(task.to_builder.target!)
    end

    render json: resp, status: 200
  end
end