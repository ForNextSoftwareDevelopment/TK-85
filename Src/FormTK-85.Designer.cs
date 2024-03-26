namespace TK85
{
    partial class FormTK_85
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
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
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormTK_85));
            this.chkToggle = new System.Windows.Forms.CheckBox();
            this.SuspendLayout();
            // 
            // chkToggle
            // 
            this.chkToggle.AutoSize = true;
            this.chkToggle.BackColor = System.Drawing.Color.Transparent;
            this.chkToggle.ForeColor = System.Drawing.Color.White;
            this.chkToggle.Location = new System.Drawing.Point(149, 295);
            this.chkToggle.Name = "chkToggle";
            this.chkToggle.Size = new System.Drawing.Size(85, 17);
            this.chkToggle.TabIndex = 0;
            this.chkToggle.Text = "Toggle Keys";
            this.chkToggle.UseVisualStyleBackColor = false;
            // 
            // FormTK_85
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.DarkGreen;
            this.BackgroundImage = global::TK85.Properties.Resources.pcb;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.ClientSize = new System.Drawing.Size(624, 729);
            this.ControlBox = false;
            this.Controls.Add(this.chkToggle);
            this.DoubleBuffered = true;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximumSize = new System.Drawing.Size(640, 768);
            this.MinimumSize = new System.Drawing.Size(640, 768);
            this.Name = "FormTK_85";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TK-85";
            this.Load += new System.EventHandler(this.FormTK_85_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        public System.Windows.Forms.CheckBox chkToggle;
    }
}