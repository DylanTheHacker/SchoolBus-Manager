using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using BLL;
using Common;
using System.IO;
using System.Web.Script.Serialization;
using Model;

namespace WebBus
{
    /// <summary>
    /// Login 的摘要说明
    /// </summary>
    public class Login : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            BLLDrivers dri = new BLLDrivers();

            Utils.WriteTraceLog("Login start");
            context.Response.ContentType = "text/html";
            StreamReader reader = new StreamReader(context.Request.InputStream);
            string str = reader.ReadToEnd();

            Dictionary<string, object> dict = new Dictionary<string, object>();
            JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
            //获取到登录信息
            string ResultCode = string.Empty;
            var jarr = jsSerializer.Deserialize<Dictionary<String, object>>(str);
            string userID = jarr["userid"] == null ? string.Empty : jarr["userid"].ToString();
            string userPWD = jarr["userpwd"] == null ? string.Empty : jarr["userpwd"].ToString();
            if (String.IsNullOrEmpty(userID) || String.IsNullOrEmpty(userPWD))
            {
                ResultCode = "2101";
            }
            

            //走家长登录流程
            else if (!dri.isDriver(userID))
            {
                BLLUsers bllUsers = new BLLUsers();
                string tokenStr = bllUsers.GetAccessToken(userID, Utils.GetMD5FromString(userPWD));
                if (tokenStr != null && tokenStr != string.Empty)
                {
                    //家长登录成功，返回所需内容
                    ResultCode = "0000";
                    dict.Add("AccessToken", tokenStr);
                    UserInfo userInfo = bllUsers.GetuserInfo(userID);
                    dict.Add("Userid", userInfo.userid);
                    dict.Add("Username", userInfo.username);
                    dict.Add("Address", userInfo.address);
                    dict.Add("Role",userInfo.role);
                }
                else
                {
                    //登录不成功
                    ResultCode = "2102";
                }
            }
            //走司机登录流程
            else
            {
                BLLDrivers bllDrivers = new BLLDrivers();
                string tokenStr = bllDrivers.GetAccessToken(userID, Utils.GetMD5FromString(userPWD));
                if (tokenStr != null && tokenStr != string.Empty)
                {
                    //家长登录成功，返回所需内容
                    ResultCode = "0000";
                    dict.Add("AccessToken", tokenStr);
                    DriverModel driveInfo = bllDrivers.GetDriverInfo(userID, Utils.GetMD5FromString(userPWD));
                    dict.Add("Userid", driveInfo.driverid);
                    dict.Add("Username", driveInfo.drivername);
                    dict.Add("Address", driveInfo.address);
                    dict.Add("Role", "driver");
                }
                else
                {
                    //登录不成功
                    ResultCode = "2102";
                }
            }
            dict.Add("ResultCode", ResultCode);
            context.Response.Write(jsSerializer.Serialize(dict));
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}