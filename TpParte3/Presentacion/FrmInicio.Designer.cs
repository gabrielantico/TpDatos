namespace TpParte3
{
    partial class FrmInicio
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            groupBox1 = new GroupBox();
            cboInicio = new ComboBox();
            BtnEntrar = new Button();
            lblInicio = new Label();
            pictureBox1 = new PictureBox();
            groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)pictureBox1).BeginInit();
            SuspendLayout();
            // 
            // groupBox1
            // 
            groupBox1.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left;
            groupBox1.BackColor = SystemColors.MenuHighlight;
            groupBox1.Controls.Add(cboInicio);
            groupBox1.Controls.Add(BtnEntrar);
            groupBox1.Controls.Add(lblInicio);
            groupBox1.ForeColor = Color.Transparent;
            groupBox1.ImeMode = ImeMode.NoControl;
            groupBox1.Location = new Point(-1, -11);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(203, 488);
            groupBox1.TabIndex = 0;
            groupBox1.TabStop = false;
            // 
            // cboInicio
            // 
            cboInicio.DropDownStyle = ComboBoxStyle.DropDownList;
            cboInicio.FormattingEnabled = true;
            cboInicio.Location = new Point(24, 77);
            cboInicio.Name = "cboInicio";
            cboInicio.Size = new Size(158, 23);
            cboInicio.TabIndex = 2;
            // 
            // BtnEntrar
            // 
            BtnEntrar.Anchor = AnchorStyles.Bottom | AnchorStyles.Left;
            BtnEntrar.BackColor = Color.MediumTurquoise;
            BtnEntrar.Font = new Font("Showcard Gothic", 9.75F, FontStyle.Regular, GraphicsUnit.Point);
            BtnEntrar.ForeColor = SystemColors.ActiveCaptionText;
            BtnEntrar.Location = new Point(46, 380);
            BtnEntrar.Name = "BtnEntrar";
            BtnEntrar.Size = new Size(111, 42);
            BtnEntrar.TabIndex = 1;
            BtnEntrar.Text = "Entrar";
            BtnEntrar.UseVisualStyleBackColor = false;
            BtnEntrar.Click += BtnEntrar_Click;
            // 
            // lblInicio
            // 
            lblInicio.AutoSize = true;
            lblInicio.Font = new Font("Showcard Gothic", 14.25F, FontStyle.Bold, GraphicsUnit.Point);
            lblInicio.Location = new Point(6, 35);
            lblInicio.Name = "lblInicio";
            lblInicio.Size = new Size(192, 23);
            lblInicio.TabIndex = 0;
            lblInicio.Text = "Power Consults";
            // 
            // pictureBox1
            // 
            pictureBox1.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            pictureBox1.Image = Properties.Resources.powerConsults;
            pictureBox1.Location = new Point(274, 24);
            pictureBox1.Name = "pictureBox1";
            pictureBox1.Size = new Size(450, 397);
            pictureBox1.SizeMode = PictureBoxSizeMode.StretchImage;
            pictureBox1.TabIndex = 1;
            pictureBox1.TabStop = false;
            // 
            // FrmInicio
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = SystemColors.ControlDarkDark;
            ClientSize = new Size(800, 450);
            Controls.Add(pictureBox1);
            Controls.Add(groupBox1);
            MinimumSize = new Size(816, 489);
            Name = "FrmInicio";
            StartPosition = FormStartPosition.CenterScreen;
            Text = "Inicio";
            Load += FrmInicio_Load;
            Resize += FrmInicio_Resize;
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)pictureBox1).EndInit();
            ResumeLayout(false);
        }

        #endregion

        private GroupBox groupBox1;
        private Label lblInicio;
        private PictureBox pictureBox1;
        private Button BtnEntrar;
        private ComboBox cboInicio;
    }
}
