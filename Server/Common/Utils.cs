using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Common
{
    public static class Utils
    {
        //获取md
        public static string GetMD5FromString(string msg)
        {
            using (MD5 md5 = MD5.Create())
            {
                byte[] msgBuffer = Encoding.UTF8.GetBytes(msg);
                byte[] md5Buffer = md5.ComputeHash(msgBuffer);
                md5.Clear();
                StringBuilder sdMd5 = new StringBuilder();
                for (int i = 0; i < md5Buffer.Length; i++)
                {
                    sdMd5.Append(md5Buffer[i].ToString("x2"));
                }
                return sdMd5.ToString();

            }
        }

        //判断密码是符合格式
        public static Boolean ValidationPwd(String pwdStr)
        {
            Regex regex = new System.Text.RegularExpressions.Regex(@"^[a-zA-Z0-9-_\d]{1,32}$");
            if (!regex.IsMatch(pwdStr))
            {
                return false;
            }

            return true;
        }

        public static Boolean ValidationLoginID(String loginID)
        {
            Regex regex = new System.Text.RegularExpressions.Regex(@"^[a-zA-Z0-9-_\d]{1,7}$");
            if (!regex.IsMatch(loginID))
            {
                return false;
            }

            return true;
        }

        public static string getRandomPassword()
        {
            Random random = new Random();
            int RandKey = random.Next(0,1000000);
            return RandKey.ToString().PadLeft(6,'0');
        }

        /// <summary>
        /// write log
        /// </summary>
        /// <param name="msg">message</param>
        /// <remarks></remarks>
        public static void WriteTraceLog(String msg)
        {
            WriteTraceLog(msg, null);
        }
        /// <summary>
        /// write trace log
        /// </summary>
        /// <param name="msg">message</param>
        /// <param name="ex">Exception</param>
        /// <remarks></remarks>
        private static void WriteTraceLog(String msg, Exception ex)
        {
            try
            {
                // make folder
                DateTime dt = DateTime.Now;
                String logFolder = System.AppDomain.CurrentDomain.BaseDirectory + "Log";

                System.IO.Directory.CreateDirectory(logFolder);

                // touch log file
                String logFile = logFolder + "\\TraceLog" + dt.ToString("yyyyMMdd") + ".log";

                // delete old log
                String logNext = logFolder + "\\TraceLog" + dt.AddDays(1).ToString("dd") + ".log";
                System.IO.File.Delete(logNext);

                // log string
                String logStr;
                logStr = dt.ToString("yyyy/MM/dd HH:mm:ss") + "\t" + msg;
                if (ex != null)
                {
                    logStr = logStr + "\n" + ex.ToString();
                }

                // Shift-JIS output
                System.IO.StreamWriter sw = null;
                try
                {
                    sw = new System.IO.StreamWriter(logFile, true,
                        System.Text.Encoding.GetEncoding("GBK"));
                    sw.WriteLine(logStr);
                }
                catch { }
                finally
                {
                    if (sw != null) sw.Close();
                }
            }
            catch { }
        }
    }
}
