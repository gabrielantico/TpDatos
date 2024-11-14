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
        }

        private void BtnEntrar_Click(object sender, EventArgs e)
        {
            FrmConsultas frmConsultas = new FrmConsultas();
            frmConsultas.ShowDialog();
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
