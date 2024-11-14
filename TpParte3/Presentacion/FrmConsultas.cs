using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;
using TpParte3.Datos;
using TpParte3.Negocio;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.ToolBar;
using ToolTip = System.Windows.Forms.ToolTip;

namespace TpParte3.Presentacion
{
    public partial class FrmConsultas : Form
    {
        private ConsultaServicio _servicio;
        private ErrorProvider errorProvider = new ErrorProvider();
        public FrmConsultas()
        {
            InitializeComponent();
        }

        private void FrmConsultas2_Load(object sender, EventArgs e)
        {
            _servicio = new ConsultaServicio();

            tabControl1.Appearance = TabAppearance.FlatButtons;
            tabControl1.ItemSize = new Size(0, 1);
            tabControl1.SizeMode = TabSizeMode.Fixed;

            ConfigurarDtps();

            CargarCombos();

            CargarCombosPanel();

            chart1.Legends[0].Enabled = true;
            chart2.Legends[0].Enabled = true;
            chart3.Legends[0].Enabled = true;
            chart4.Legends[0].Enabled = true;
            chart5.Legends[0].Enabled = true;

            //chart1.Titles.Add("Cantidad de exámenes desaprobados");
            //chart2.Titles.Add("Cantidad de exámenes aprobados");
            //chart3.Titles.Add("Promedio de notas de este año");
            //chart4.Titles.Add("Asistencias");
            //chart5.Titles.Add("Total exámenes");

            errorProvider.Icon = new Icon("D:\\Gabi\\Usuarios\\Facultad\\2do Cuatrimestre\\Bases de datos I\\TPI\\TpParte3\\TpParte3\\Resources\\favicon.ico");
            errorProvider.BlinkStyle = ErrorBlinkStyle.NeverBlink;
        }

        private void cboConsulta_1_SelectedIndexChanged(object sender, EventArgs e)
        {
            tabControl1.SelectedIndex = (int)cboConsulta_1.SelectedValue - 1;
        }

        private void cboConsulta_2_SelectedIndexChanged(object sender, EventArgs e)
        {
            tabControl1.SelectedIndex = (int)cboConsulta_2.SelectedValue - 1;
        }

        private void cboConsulta_3_SelectedIndexChanged(object sender, EventArgs e)
        {
            tabControl1.SelectedIndex = (int)cboConsulta_3.SelectedValue - 1;
        }

        private void cboConsulta_4_SelectedIndexChanged(object sender, EventArgs e)
        {
            tabControl1.SelectedIndex = (int)cboConsulta_4.SelectedValue - 1;
        }

        private void cboConsulta_5_SelectedIndexChanged(object sender, EventArgs e)
        {
            tabControl1.SelectedIndex = (int)cboConsulta_5.SelectedValue - 1;
        }

        private void CargarCombos()
        {
            var opciones = new List<Opcion>()
             {
                 new Opcion { Texto = "Reporte 1", Valor = 1 },
                 new Opcion { Texto = "Reporte 2", Valor = 2 },
                 new Opcion { Texto = "Reporte 3", Valor = 3 },
                 new Opcion { Texto = "Reporte 4", Valor = 4 },
                 new Opcion { Texto = "Reporte 5", Valor = 5 }
            };

            cboConsulta_1.DisplayMember = "Texto";
            cboConsulta_1.ValueMember = "Valor";
            cboConsulta_1.DataSource = opciones;

            cboConsulta_2.DisplayMember = "Texto";
            cboConsulta_2.ValueMember = "Valor";
            cboConsulta_2.DataSource = opciones;

            cboConsulta_3.DisplayMember = "Texto";
            cboConsulta_3.ValueMember = "Valor";
            cboConsulta_3.DataSource = opciones;

            cboConsulta_4.DisplayMember = "Texto";
            cboConsulta_4.ValueMember = "Valor";
            cboConsulta_4.DataSource = opciones;

            cboConsulta_5.DisplayMember = "Texto";
            cboConsulta_5.ValueMember = "Valor";
            cboConsulta_5.DataSource = opciones;
        }

        private void CargarCombosPanel()
        {
            DataTable dt = _servicio.TraerTodos("PROVINCIAS");

            cboProvincia_2.DataSource = dt;
            cboProvincia_2.DisplayMember = dt.Columns["nom_provincia"].ColumnName;
            cboProvincia_2.ValueMember = dt.Columns["id_provincia"].ColumnName;

            DataTable dt2 = _servicio.TraerTodos("tipos_carreras");

            cboTipoCarrera_3.DataSource = dt2;
            cboTipoCarrera_3.DisplayMember = dt2.Columns["descripcion"].ColumnName;
            cboTipoCarrera_3.ValueMember = dt2.Columns["id_tipo_carrera"].ColumnName;

            DataTable dt3 = _servicio.TraerTodos("carreras");
            cboCarrera_5.DataSource = dt3;
            cboCarrera_5.DisplayMember = dt3.Columns["descripcion"].ColumnName;
            cboCarrera_5.ValueMember = dt3.Columns["id_carrera"].ColumnName;
        }

        private void ConfigurarDtps()
        {
            dtpFecha1_1.MaxDate = DateTime.Now;
            dtpFecha2_1.MaxDate = DateTime.Now;

            dtpFecha1_2.MaxDate = DateTime.Now;
            dtpFecha2_2.MaxDate = DateTime.Now;

            dtpAnio_3.MaxDate = DateTime.Now.AddYears(-1);

            dtpFecha1_4.MaxDate = DateTime.Now;
            dtpFecha2_4.MaxDate = DateTime.Now;

            dtpFecha1_5.MaxDate = DateTime.Now;
            dtpFecha2_5.MaxDate = DateTime.Now;
        }

        private void btnConsultar_1_Click(object sender, EventArgs e)
        {
            errorProvider.Clear();
            //Validaciones

            //Que esten rellenados los campos

            if (dtpFecha1_1.Value == null)
            {
                MessageBox.Show("Ingrese la Fecha N°1", "Ejecución no admitida", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (dtpFecha2_1.Value == null)
            {
                MessageBox.Show("Ingrese la Fecha N°2", "Ejecución no admitida", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            //Que esten bien los campos

            if (dtpFecha1_1.Value.Date > dtpFecha2_1.Value.Date)
            {
                MessageBox.Show("La fecha N° 2 debe ser más reciente que la fecha N°1", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            bool trabaja = chkTrabaja_1.Checked;

            bool aprobado = chkAprobado_1.Checked;

            var parametros = new List<Parametro>()
            {
                new Parametro("@trabaja", trabaja),
                new Parametro("@aprobado", aprobado),
                new Parametro("@fecha1", dtpFecha1_1.Value),
                new Parametro("@fecha2", dtpFecha2_1.Value)
            };

            if (chkAprobado_1.Checked)
            {
                dgv_1.Columns["Col2_1"].HeaderText = "Exámenes aprobados";
            }
            else
            {
                dgv_1.Columns["Col2_1"].HeaderText = "Exámenes desaprobados";
            }

            DataTable dt = _servicio.EjecturaSp("sp_consulta1", parametros);

            dgv_1.Rows.Clear();

            chart1.Series[0].Points.Clear();

            chart1.Titles.Clear();

            if (dt.Rows.Count > 0)
            {

                if (chkAprobado_1.Checked)
                {
                    chart1.Titles.Add("Cantidad de exámenes aprobados");
                }
                else
                {      
                    chart1.Titles.Add("Cantidad de exámenes desaprobados");
                }

                

                List<string> nombres = new List<string>();

                foreach (DataRow row in dt.Rows)
                {
                    dgv_1.Rows.Add(row[0], row[1], row[2]);

                    chart1.Series[0].Points.AddXY(row[0], row[1]);
                    nombres.Add(row[0].ToString());
                }
                int contador = 0;
                foreach (var point in chart1.Series[0].Points)
                {
                    point.IsValueShownAsLabel = false;
                    point.Label = "";
                    point.AxisLabel = "";
                    point.LegendText = nombres[contador];
                    contador++;
                }
            }
            else
            { 
                errorProvider.SetError(btnConsultar_1, "No se encontraron registros para mostrar.");
            }
        }

        private void btnConsultar_2_Click(object sender, EventArgs e)
        {
            errorProvider.Clear();

            //Validaciones

            //Que esten rellenados los campos

            if (dtpFecha1_2.Value == null)
            {
                MessageBox.Show("Ingrese la Fecha N°1", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (dtpFecha2_2.Value == null)
            {
                MessageBox.Show("Ingrese la Fecha N°2", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (cboProvincia_2.SelectedIndex == -1)
            {
                MessageBox.Show("Debe seleccionar al menos una provincia", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtPromedio_2.Text))
            {
                MessageBox.Show("Debe escribir un valor promedio para filtrar", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtAprobados_2.Text))
            {
                MessageBox.Show("Debe escribir una cantidad de exámenes aprobados para filtrar", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            //Que esten bien los campos

            if (dtpFecha1_2.Value.Date > dtpFecha2_2.Value.Date)
            {
                MessageBox.Show("La fecha N° 2 debe ser más reciente que la fecha N°1", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(txtPromedio_2.Text, @"^\d+(\,\d+)?$"))
            {
                MessageBox.Show("Formato del promedio incorrecto", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (!double.TryParse(txtPromedio_2.Text, out _))
            {
                MessageBox.Show("Formato del promedio incorrecto", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (!int.TryParse(txtAprobados_2.Text, out _))
            {
                MessageBox.Show("Formato de cantidad de exámenes incorrecto", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (Convert.ToDouble(txtPromedio_2.Text) > 10)
            {
                MessageBox.Show("Promedio máximo admitido: 10", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            }

            var parametros = new List<Parametro>()
            {
                new Parametro("@fecha1", dtpFecha1_2.Value),
                new Parametro("@fecha2", dtpFecha2_2.Value),
                new Parametro("@provincia", cboProvincia_2.SelectedValue),
                new Parametro("@promedio", float.Parse(txtPromedio_2.Text)),
                new Parametro("@aprobados", Convert.ToInt32(txtAprobados_2.Text))
            };

            DataTable dt = _servicio.EjecturaSp("sp_consulta2", parametros);

            dgv_2.Rows.Clear();

            chart2.Series[0].Points.Clear();

            chart2.Titles.Clear();

            if (dt.Rows.Count > 0)
            {

                chart2.Titles.Add("Cantidad de exámenes aprobados");

                List<string> nombres_2 = new List<string>();

                foreach (DataRow row in dt.Rows)
                {
                    dgv_2.Rows.Add(row[0], row[1], row[2], row[3], row[4]);
                    chart2.Series[0].Points.AddXY(row[0], row[4]);
                    nombres_2.Add(row[0].ToString());
                }

                int contador = 0;

                foreach (var point in chart2.Series[0].Points)
                {
                    point.IsValueShownAsLabel = false;
                    point.Label = "";
                    point.AxisLabel = "";
                    point.LegendText = nombres_2[contador];
                    contador++;
                }
            }
            else
            {
                errorProvider.SetError(btnConsultar_2, "No se encontraron registros para mostrar.");
            }
        }

        private void txtPromedio_2_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar) && e.KeyChar != ',')
            {
                e.Handled = true;
            }
        }

        private void txtAprobados_2_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }

        private void btnConsultar_3_Click(object sender, EventArgs e)
        {
            errorProvider.Clear();

            //Validaciones

            //Que esten rellenados los campos

            if (cboTipoCarrera_3.SelectedIndex == -1)
            {
                MessageBox.Show("Debe seleccionar un tipo de carrera", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (dtpAnio_3.Value == null)
            {
                MessageBox.Show("Debe ingresar un año", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (!rbtMayor_3.Checked && !rbtMenor_3.Checked)
            {
                MessageBox.Show("Debe seleccionar mayor o menor promedio", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            bool mayor;

            if (rbtMayor_3.Checked)
            {
                mayor = true;
            }
            else
            {
                mayor = false;
            }

            var parametros = new List<Parametro>()
            {
                new Parametro("@tipoCarrera", cboTipoCarrera_3.SelectedValue),
                new Parametro("@mayorPromedio", mayor),
                new Parametro("@anio", dtpAnio_3.Value.Year)
            };

            DataTable dt = _servicio.EjecturaSp("sp_consulta3", parametros);

            dgv_3.Rows.Clear();

            chart3.Series[0].Points.Clear();

            chart3.Titles.Clear();

            if (dt.Rows.Count > 0)
            {
                chart3.Titles.Add("Promedio de notas de este año");

                List<string> nombres_3 = new List<string>();

                foreach (DataRow row in dt.Rows)
                {
                    dgv_3.Rows.Add(row[0], row[1], row[2], row[3]);

                    chart3.Series[0].Points.AddXY(row[0], row[3]);
                    nombres_3.Add(row[0].ToString());
                }
                int contador = 0;
                foreach (var point in chart3.Series[0].Points)
                {
                    point.IsValueShownAsLabel = false;
                    point.Label = "";
                    point.AxisLabel = "";
                    point.LegendText = nombres_3[contador];
                    contador++;
                }
            }
            else
            {
                errorProvider.SetError(btnConsultar_3, "No se encontraron registros para mostrar.");
            }
        }

        private void dtpAnio_3_ValueChanged(object sender, EventArgs e)
        {
            dgv_3.Columns["Col3_3"].HeaderText = $"Promedio de notas de {dtpAnio_3.Value.Year}";
        }

        private void btnConsultar_4_Click(object sender, EventArgs e)
        {
            errorProvider.Clear();

            //Validaciones

            //Que esten rellenados los campos

            if (dtpFecha1_4.Value == null)
            {
                MessageBox.Show("Ingrese la Fecha N°1", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (dtpFecha2_4.Value == null)
            {
                MessageBox.Show("Ingrese la Fecha N°2", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtPromedio_4.Text))
            {
                MessageBox.Show("Debe escribir un valor promedio para filtrar", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            //Que esten bien los campos

            if (dtpFecha1_4.Value.Date > dtpFecha2_4.Value.Date)
            {
                MessageBox.Show("La fecha N° 2 debe ser más reciente que la fecha N°1", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(txtPromedio_4.Text, @"^\d+(\,\d+)?$"))
            {
                MessageBox.Show("Formato del promedio incorrecto", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (!double.TryParse(txtPromedio_4.Text, out _))
            {
                MessageBox.Show("Formato del promedio incorrecto", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if(Convert.ToDouble(txtPromedio_4.Text) > 10)
            {
                MessageBox.Show("Promedio máximo admitido: 10", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            }

            var parametros = new List<Parametro>()
            {
                new Parametro("@promedioMinimo", float.Parse(txtPromedio_4.Text)),
                new Parametro("@fecha1", dtpFecha1_4.Value),
                new Parametro("@fecha2", dtpFecha2_4.Value)
            };

            DataTable dt = _servicio.EjecturaSp("sp_consulta4", parametros);

            dgv_4.Rows.Clear();

            chart4.Series[0].Points.Clear();

            chart4.Titles.Clear();

            if (dt.Rows.Count > 0)
            {
                chart4.Titles.Add("Asistencias");

                List<string> nombres_4 = new List<string>();

                foreach (DataRow row in dt.Rows)
                {
                    dgv_4.Rows.Add(row[0], row[1], row[2], row[3]);

                    chart4.Series[0].Points.AddXY(row[0], row[2]);
                    nombres_4.Add(row[0].ToString());
                }
                int contador = 0;
                foreach (var point in chart4.Series[0].Points)
                {
                    point.IsValueShownAsLabel = false;
                    point.Label = "";
                    point.AxisLabel = "";
                    point.LegendText = nombres_4[contador];
                    contador++;
                }
            }
            else
            {
                errorProvider.SetError(btnConsultar_4, "No se encontraron registros para mostrar.");
            }
        }

        private void txtPromedio_4_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar) && e.KeyChar != ',')
            {
                e.Handled = true;
            }
        }

        private void btnConsultar_5_Click(object sender, EventArgs e)
        {
            errorProvider.Clear();

            //Validaciones

            //Que esten rellenados los campos

            if (dtpFecha1_5.Value == null)
            {
                MessageBox.Show("Ingrese la Fecha N°1", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (dtpFecha2_5.Value == null)
            {
                MessageBox.Show("Ingrese la Fecha N°2", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            if (cboCarrera_5.SelectedIndex == -1)
            {
                MessageBox.Show("Debe seleccionar una carrera", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            //Que los campos esten bien

            if (dtpFecha1_5.Value.Date > dtpFecha2_5.Value.Date)
            {
                MessageBox.Show("La fecha N° 2 debe ser más reciente que la fecha N°1", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            var parametros = new List<Parametro>()
            {
                new Parametro("@carrera", cboCarrera_5.SelectedValue),
                new Parametro("@fecha_inicio", dtpFecha1_5.Value),
                new Parametro("@fecha_fin", dtpFecha2_5.Value)
            };

            DataTable dt = _servicio.EjecturaSp("sp_consulta5", parametros);

            dgv_5.Rows.Clear();

            chart5.Series[0].Points.Clear();

            chart5.Titles.Clear();

            if (dt.Rows.Count > 0)
            {
                chart5.Titles.Add("Total exámenes");

                List<string> nombres_5 = new List<string>();

                foreach (DataRow row in dt.Rows)
                {
                    dgv_5.Rows.Add(row[0], row[1], row[2], row[3], row[4]);

                    chart5.Series[0].Points.AddXY(row[0], row[2]);
                    nombres_5.Add(row[0].ToString());
                }
                int contador = 0;
                foreach (var point in chart5.Series[0].Points)
                {
                    point.IsValueShownAsLabel = false;
                    point.Label = "";
                    point.AxisLabel = "";
                    point.LegendText = nombres_5[contador];
                    contador++;
                }
            }
            else
            {
                errorProvider.SetError(btnConsultar_5, "No se encontraron registros para mostrar.");
            }
        }

        private void txtPromedio_2_Validating(object sender, CancelEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(txtPromedio_2.Text))
            {
                if (!txtPromedio_2.Text.All(c => char.IsDigit(c) || c == ','))
                {
                    MessageBox.Show("Solo se admiten números decimales", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    e.Cancel = true;
                }
            }
        }

        private void txtAprobados_2_Validating(object sender, CancelEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(txtAprobados_2.Text))
            {
                if (!txtAprobados_2.Text.All(c => char.IsDigit(c)))
                {
                    MessageBox.Show("Solo se admiten números enteros", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    e.Cancel = true;
                }
            }
        }

        private void txtPromedio_4_Validating(object sender, CancelEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(txtPromedio_4.Text))
            {
                if (!txtPromedio_4.Text.All(c => char.IsDigit(c) || c == ','))
                {
                    MessageBox.Show("Solo se admiten números decimales", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    e.Cancel = true;
                }
            }
        }
    }
}
