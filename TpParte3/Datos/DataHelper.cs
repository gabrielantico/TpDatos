using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TpParte3.Datos
{
    public class DataHelper
    {
        public static DataHelper helper;
        private SqlConnection _cnn;
        private string cadenaConexion = @"Data Source=DESKTOP-VSD47N1\DATABASEGABI;Initial Catalog=SIS_ACADEMICO_DEFINITIVO;Integrated Security=True;Encrypt=False";

        private DataHelper()
        {
            _cnn = new SqlConnection(cadenaConexion);
        }

        public static DataHelper ObtenerHelper()
        {
            if (helper == null)
            {
                helper = new DataHelper();
            }
            return helper;
        }

        public DataTable EjecutarSp(string nombreSp, List<Parametro>? parametros)
        {
            DataTable dt = new DataTable();
            try
            {
                _cnn.Open();

                SqlCommand cmd = new SqlCommand(nombreSp, _cnn);
                cmd.CommandType = CommandType.StoredProcedure;

                if (parametros != null && parametros.Count > 0)
                {
                    foreach (var p in parametros)
                    {
                        cmd.Parameters.AddWithValue(p.Nombre, p.Valor);
                    }
                }

                dt.Load(cmd.ExecuteReader());

                return dt;
            }
            catch (Exception ex)
            {
                throw new Exception("Error al ejecutar el método");
            }
            finally
            {
                if(_cnn.State == ConnectionState.Open)
                {
                    _cnn.Close();
                }
            }
        }

        public DataTable TraerTodos(string nombreTabla)
        {
            DataTable dt = new DataTable();

            try
            {
                _cnn.Open();

                SqlCommand cmd = new SqlCommand($"select * from {nombreTabla}", _cnn);
                cmd.CommandType = CommandType.Text;

                dt.Load(cmd.ExecuteReader());

                return dt;
            }
            catch (Exception ex)
            {
                throw new Exception("Error al ejecutar el método");
            }
            finally
            {
                if(_cnn.State == ConnectionState.Open)
                {
                    _cnn.Close();
                }
            }
        }
    }
}
