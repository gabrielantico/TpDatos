using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TpParte3.Datos;

namespace TpParte3.Negocio
{
    public class ConsultaServicio
    {
        private ConsultaRepositorio _repositorio;

        public ConsultaServicio()
        {
            _repositorio = new ConsultaRepositorio();
        }

        public DataTable EjecturaSp(string nombreSp, List<Parametro>? parametros)
        {
            return _repositorio.EjecutarSp(nombreSp, parametros);
        }

        public DataTable TraerTodos(string nombreTabla)
        {
            return _repositorio.TraerTodos(nombreTabla);
        }
    }
}
