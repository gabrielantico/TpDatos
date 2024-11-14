using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TpParte3.Datos
{
    public class ConsultaRepositorio
    {
        private DataHelper _dataHelper;

        public ConsultaRepositorio()
        {
            _dataHelper = DataHelper.ObtenerHelper();
        }

        public DataTable EjecutarSp(string nombreSp, List<Parametro>? parametros)
        {
            return _dataHelper.EjecutarSp(nombreSp, parametros);
        }

        public DataTable TraerTodos(string nombreTabla)
        {
            return _dataHelper.TraerTodos(nombreTabla);
        }
    }
}
