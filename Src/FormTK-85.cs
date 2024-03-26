using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TK85
{
    public partial class FormTK_85 : Form
    {
        #region Members

        // Led display 
        public SevenSegment sevenSegmentAddress0;
        public SevenSegment sevenSegmentAddress1;
        public SevenSegment sevenSegmentAddress2;
        public SevenSegment sevenSegmentAddress3;
        public SevenSegment sevenSegmentData0;
        public SevenSegment sevenSegmentData1;
        public SevenSegment sevenSegmentData2;
        public SevenSegment sevenSegmentData3;

        // Keyboard
        public Key keyReset;
        public Key keyCont;
        public Key keyRun;
        public Key keyMode;
        public Key keyReg;
        public Key keyMon;
        public Key keyC;
        public Key keyD;
        public Key keyE;
        public Key keyF;
        public Key keyAdrsSet;
        public Key key8;
        public Key key9;
        public Key keyA;
        public Key keyB;
        public Key keyReadInc;
        public Key key4;
        public Key key5;
        public Key key6;
        public Key key7;
        public Key keyReadDec;
        public Key key0;
        public Key key1;
        public Key key2;
        public Key key3;
        public Key keyWrEnt;

        // Initial location of window
        int x, y;

        #endregion

        #region Constructor

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        public FormTK_85(int x, int y)
        {
            InitializeComponent();

            this.x = x;
            this.y = y;

            // Most left digit
            sevenSegmentAddress3 = new SevenSegment();
            sevenSegmentAddress3.Location = new Point(34, 44);
            Controls.Add(sevenSegmentAddress3);

            sevenSegmentAddress2 = new SevenSegment();
            sevenSegmentAddress2.Location = new Point(sevenSegmentAddress3.Width + 36, 44);
            Controls.Add(sevenSegmentAddress2);

            sevenSegmentAddress1 = new SevenSegment();
            sevenSegmentAddress1.Location = new Point(sevenSegmentAddress3.Width + sevenSegmentAddress2.Width + 38, 44);
            Controls.Add(sevenSegmentAddress1);

            sevenSegmentAddress0 = new SevenSegment();
            sevenSegmentAddress0.Location = new Point(sevenSegmentAddress3.Width + sevenSegmentAddress2.Width + sevenSegmentAddress1.Width + 40, 44);
            Controls.Add(sevenSegmentAddress0);

            sevenSegmentData3 = new SevenSegment();
            sevenSegmentData3.Location = new Point(sevenSegmentAddress3.Width + sevenSegmentAddress2.Width + sevenSegmentAddress1.Width + sevenSegmentAddress0.Width + 64, 44);
            Controls.Add(sevenSegmentData3);

            sevenSegmentData2 = new SevenSegment();
            sevenSegmentData2.Location = new Point(sevenSegmentAddress3.Width + sevenSegmentAddress2.Width + sevenSegmentAddress1.Width + sevenSegmentAddress0.Width + sevenSegmentData3.Width + 66, 44);
            Controls.Add(sevenSegmentData2);

            sevenSegmentData1 = new SevenSegment();
            sevenSegmentData1.Location = new Point(sevenSegmentAddress3.Width + sevenSegmentAddress2.Width + sevenSegmentAddress1.Width + sevenSegmentAddress0.Width + sevenSegmentData3.Width + sevenSegmentData2.Width + 68, 44);
            Controls.Add(sevenSegmentData1);

            // Most right digit
            sevenSegmentData0 = new SevenSegment();
            sevenSegmentData0.Location = new Point(sevenSegmentAddress3.Width + sevenSegmentAddress2.Width + sevenSegmentAddress1.Width + sevenSegmentAddress0.Width + sevenSegmentData3.Width + sevenSegmentData2.Width + +sevenSegmentData1.Width + 70, 44);
            Controls.Add(sevenSegmentData0);

            // Reset key
            keyReset = new Key(70, 70, true, "RESET");
            keyReset.Location = new Point(460, 250);
            keyReset.ForeColor = Color.White;
            keyReset.ColorCenter = Color.Black; 
            keyReset.ColorBorder = Color.DarkGray;
            Controls.Add(keyReset);

            // Button positions
            int startX = 154;
            int startY = 326;

            keyCont = new Key(70, 70, true, "CONT");
            keyCont.Location = new Point(startX, startY);
            Controls.Add(keyCont);

            startX += keyCont.Width + 14;

            keyRun = new Key(70, 70, true, "RUN");
            keyRun.Location = new Point(startX, startY);
            Controls.Add(keyRun);

            startX += keyRun.Width + 14;

            keyMode = new Key(70, 70, true, "MODE");
            keyMode.Location = new Point(startX, startY);
            Controls.Add(keyMode);

            startX += keyMode.Width + 14;

            keyReg = new Key(70, 70, true, "REG");
            keyReg.Location = new Point(startX, startY);
            Controls.Add(keyReg);

            startX += keyReg.Width + 14;

            keyMon = new Key(70, 70, true, "MON");
            keyMon.Location = new Point(startX, startY);
            Controls.Add(keyMon);

            startX = 154;
            startY += keyMon.Height + 10;

            keyC = new Key(70, 70, false, "C", "TM");
            keyC.Location = new Point(startX, startY);
            Controls.Add(keyC);

            startX += keyC.Width + 14;

            keyD = new Key(70, 70, false, "D", "MOV");
            keyD.Location = new Point(startX, startY);
            Controls.Add(keyD);

            startX += keyD.Width + 14;

            keyE = new Key(70, 70, false, "E", "OUT");
            keyE.Location = new Point(startX, startY);
            Controls.Add(keyE);

            startX += keyE.Width + 14;

            keyF = new Key(70, 70, false, "F", "IN");
            keyF.Location = new Point(startX, startY);
            Controls.Add(keyF);

            startX += keyF.Width + 14;

            keyAdrsSet = new Key(70, 70, true, "ADRS", "SET");
            keyAdrsSet.Location = new Point(startX, startY);
            Controls.Add(keyAdrsSet);

            startX = 154;
            startY += keyAdrsSet.Height + 10;

            key8 = new Key(70, 70, false, "8");
            key8.Location = new Point(startX, startY);
            Controls.Add(key8);

            startX += key8.Width + 14;

            key9 = new Key(70, 70, false, "9");
            key9.Location = new Point(startX, startY);
            Controls.Add(key9);

            startX += key9.Width + 14;

            keyA = new Key(70, 70, false, "A", "SAVE");
            keyA.Location = new Point(startX, startY);
            Controls.Add(keyA);

            startX += keyA.Width + 14;

            keyB = new Key(70, 70, false, "B", "LOAD");
            keyB.Location = new Point(startX, startY);
            Controls.Add(keyB);

            startX += keyB.Width + 14;

            keyReadInc = new Key(70, 70, true, "READ", "INC");
            keyReadInc.Location = new Point(startX, startY);
            Controls.Add(keyReadInc);

            startX = 154;
            startY += keyReadInc.Height + 10;

            key4 = new Key(70, 70, false, "4", "SP");
            key4.Location = new Point(startX, startY);
            Controls.Add(key4);

            startX += key4.Width + 14;

            key5 = new Key(70, 70, false, "5", "BR.P");
            key5.Location = new Point(startX, startY);
            Controls.Add(key5);

            startX += key5.Width + 14;

            key6 = new Key(70, 70, false, "6", "BR.D");
            key6.Location = new Point(startX, startY);
            Controls.Add(key6);

            startX += key6.Width + 14;

            key7 = new Key(70, 70, false, "7");
            key7.Location = new Point(startX, startY);
            Controls.Add(key7);

            startX += key7.Width + 14;

            keyReadDec = new Key(70, 70, true, "READ", "DEC");
            keyReadDec.Location = new Point(startX, startY);
            Controls.Add(keyReadDec);

            startX = 154;
            startY += keyReadDec.Height + 10;

            key0 = new Key(70, 70, false, "0", "AF");
            key0.Location = new Point(startX, startY);
            Controls.Add(key0);

            startX += key0.Width + 14;

            key1 = new Key(70, 70, false, "1", "BC");
            key1.Location = new Point(startX, startY);
            Controls.Add(key1);

            startX += key1.Width + 14;

            key2 = new Key(70, 70, false, "2", "DE");
            key2.Location = new Point(startX, startY);
            Controls.Add(key2);

            startX += key2.Width + 14;

            key3 = new Key(70, 70, false, "3", "HL");
            key3.Location = new Point(startX, startY);
            Controls.Add(key3);

            startX += key3.Width + 14;

            keyWrEnt = new Key(70, 70, true, "WR", "ENT");
            keyWrEnt.Location = new Point(startX, startY);
            Controls.Add(keyWrEnt);
        }

        #endregion

        #region EventHandlers

        /// <summary>
        /// Form loaded
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormTK_85_Load(object sender, EventArgs e)
        {
            // Set location of window
            this.Location = new Point(x, y); 
        }

        #endregion
    }
}
