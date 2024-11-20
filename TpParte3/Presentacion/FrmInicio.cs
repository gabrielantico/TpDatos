using TpParte3.Presentacion;

namespace TpParte3
{
    public partial class FrmInicio : Form
    {

        private float aspectRatio;
        public FrmInicio()
        {
            InitializeComponent();
        }

        private void FrmInicio_Load(object sender, EventArgs e)
        {
            aspectRatio = (float)this.Width / this.Height;

            var opcionesInicio = new List<Opcion>()
            {
                new Opcion { Texto = "Consultas", Valor = 1 },
                new Opcion { Texto = "Nosotros", Valor = 2 }
            };

            cboInicio.ValueMember = "Valor";
            cboInicio.DisplayMember = "Texto";
            cboInicio.DataSource = opcionesInicio;
        }

        private void BtnEntrar_Click(object sender, EventArgs e)
        {
            if((int)cboInicio.SelectedValue == 1)
            {
                FrmConsultas frmConsultas = new FrmConsultas();
                frmConsultas.ShowDialog();
            }
            else
            {
                FrmNosotros frmNosotros = new FrmNosotros();
                frmNosotros.ShowDialog();
            }
        }

        private void FrmInicio_Resize(object sender, EventArgs e)
        {
            int newWidth = this.Width;
            int newHeight = (int)(newWidth / aspectRatio);

            // Actualiza el tamaño del formulario manteniendo la relación de aspecto
            this.Size = new Size(newWidth, newHeight);
        }
    }
}
