using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Drawing.Drawing2D;
using System.Diagnostics.Eventing.Reader;

namespace TK85
{
    public partial class Key: UserControl
    {
        #region Members

        private bool pressed = false;

        private int radiusCenter = 16;
        private int radiusBorder = 20;
        private int widthBorder = 8;
        private Color colorBackground = Color.Transparent;
        private Color colorBorder = Color.GhostWhite;
        private Color colorCenter = Color.Snow;

        // Control key
        private bool control;

        // Text on the button
        private string text1;
        private string text2;

        // Button pressed
        public bool Pressed { get { return pressed; } set { pressed = value; Invalidate(); } }

        // Radius of rounded center box corners
        public int RadiusCenter { get { return radiusCenter; } set { radiusCenter = value; Invalidate(); } }

        // Radius of rounded border corners
        public int RadiusBorder { get { return radiusBorder; } set { radiusBorder = value; Invalidate(); } }

        // Width of border
        public int WidthBorder { get { return widthBorder; } set { widthBorder = value; Invalidate(); } }

        // Background color
        public Color ColorBackground { get { return colorBackground; } set { colorBackground = value; Invalidate(); } }

        // Color of key edge
        public Color ColorBorder { get { return colorBorder; } set { colorBorder = value; Invalidate(); } }

        // Color of key
        public Color ColorCenter { get { return colorCenter; } set { colorCenter = value; Invalidate(); } }

        #endregion

        #region Constructor

        /// <summary>
        /// Base constructor
        /// </summary>
        public Key()
        {
            SuspendLayout();

            text1 = "Key";
            text2 = "";

            control = false;

            Name = "Key";

            ForeColor = Color.DarkRed;
            Size = new Size(70, 70);
            Paint += new PaintEventHandler(Key_Paint);
            Resize += new EventHandler(Key_Resize);

            TabStop = false;
            DoubleBuffered = true;

            ResumeLayout();
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="width"></param>
        /// <param name="height"></param>
        /// <param name="control"></param>
        /// <param name="text1"></param>
        /// <param name="text2"></param>
        public Key(int width, int height, bool control, string text1, string text2 = "")
        {
            SuspendLayout();

            this.control = control;

            this.text1 = text1;
            this.text2 = text2;

            ForeColor = Color.DarkRed;

            if (control)
            {
                ForeColor = Color.White;
                ColorCenter = Color.DarkRed;
                ColorBorder = Color.IndianRed;
            }

            Name = "Key" + text1 + text2;

            Size = new Size(width, height);
            Paint += new PaintEventHandler(Key_Paint);
            Resize += new EventHandler(Key_Resize);

            TabStop = false;
            DoubleBuffered = true;

            ResumeLayout();
        }

        #endregion

        #region EventHandlers

        /// <summary>
        /// Button clicked
        /// </summary>
        /// <param name="e"></param>
        protected override void OnMouseDown(MouseEventArgs e)
        {
            foreach (Control control in Parent.Controls)
            {
                if (control.Name == "chkToggle")
                {
                    CheckBox chkToggle = (CheckBox)control;
                    if (!chkToggle.Checked)
                    {
                        Pressed = true;
                    } else
                    {
                        Pressed = !Pressed;
                    }
                }
            }
            base.OnMouseDown(e);
        }

        /// <summary>
        /// Button released
        /// </summary>
        /// <param name="e"></param>
        protected override void OnMouseUp(MouseEventArgs e)
        {
            foreach (Control control in Parent.Controls)
            {
                if (control.Name == "chkToggle")
                {
                    CheckBox chkToggle = (CheckBox)control;
                    if (!chkToggle.Checked) Pressed = false;
                }
            }
            base.OnMouseUp(e);
        }

        /// <summary>
        /// (Re-)Paint background
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPaintBackground(PaintEventArgs e)
        {
            // base.OnPaintBackground(e);
            e.Graphics.Clear(colorBackground);
        }

        /// <summary>
        /// Key resized
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Key_Resize(object sender, EventArgs e) { Invalidate(); }

        /// <summary>
        /// (Re-)Paint 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Key_Paint(object sender, PaintEventArgs e)
        {
            Brush brushCenter = new SolidBrush(colorCenter);
            if (pressed) brushCenter = new SolidBrush(Color.Red);
            Pen penBorder = new Pen(colorBorder, widthBorder);

            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
            e.Graphics.PixelOffsetMode = PixelOffsetMode.Default;

            GraphicsPath path = new GraphicsPath();
            Rectangle corner = new Rectangle(0, 0, radiusCenter, radiusCenter);
            path.AddArc(corner, 180, 90);
            
            corner.X = Width - radiusCenter;
            path.AddArc(corner, 270, 90);
            
            corner.Y = Height - radiusCenter;
            path.AddArc(corner, 0, 90);
            
            corner.X = 0;
            path.AddArc(corner, 90, 90);
            
            path.CloseFigure();

            e.Graphics.FillPath(brushCenter, path);

            GraphicsPath pathBorder = new GraphicsPath();
            Rectangle cornerBorder = new Rectangle(0, 0, radiusBorder, radiusBorder);
            pathBorder.AddArc(cornerBorder, 180, 90);
            
            cornerBorder.X = Width - radiusBorder - 1;
            pathBorder.AddArc(cornerBorder, 270, 90);

            cornerBorder.Y = Height - radiusBorder - 1;
            pathBorder.AddArc(cornerBorder, 0, 90);

            cornerBorder.X = 0;
            pathBorder.AddArc(cornerBorder, 90, 90);

            pathBorder.CloseFigure();

            e.Graphics.DrawPath(penBorder, pathBorder);

            Font font = new Font("Tahoma", 16.0F, FontStyle.Regular);
            Font fontControl = new Font("Tahoma", 14.0F, FontStyle.Regular);
            Font fontBig = new Font("Tahoma", 18.0F, FontStyle.Bold);

            if (control)
            {
                if (text2 != "")
                {
                    // 2 text lines,
                    e.Graphics.DrawString(text1, fontControl, new SolidBrush(ForeColor), (Width - e.Graphics.MeasureString(text1, fontControl).Width) / 2, Height / 2 - fontControl.Height);
                    e.Graphics.DrawString(text2, fontControl, new SolidBrush(ForeColor), (Width - e.Graphics.MeasureString(text2, fontControl).Width) / 2, Height / 2);
                } else
                {
                    // Big text 
                    e.Graphics.DrawString(text1, fontControl, new SolidBrush(ForeColor), (Width - e.Graphics.MeasureString(text1, fontControl).Width) / 2, Height / 2 - fontControl.Height / 2);
                }
            } else
            {
                e.Graphics.DrawString(text1, fontBig, new SolidBrush(ForeColor), (Width - e.Graphics.MeasureString(text1, fontBig).Width) / 2, Height / 2 - fontBig.Height);
                if (text2 != "")
                {
                    // 2 text lines,
                    e.Graphics.DrawString(text2, font, new SolidBrush(ForeColor), (Width - e.Graphics.MeasureString(text2, font).Width) / 2, Height / 2);
                }
            }
        }

        #endregion
    }
}
