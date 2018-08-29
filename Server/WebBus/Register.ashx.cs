using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Web.Script.Serialization;
using Model;
using BLL;
using Common;

namespace WebBus
{
    /// <summary>
    /// Register 的摘要说明
    /// </summary>
    public class Register : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            Utils.WriteTraceLog("register start");
            context.Response.ContentType = "text/html";
            try
            {               
                StreamReader reader = new StreamReader(context.Request.InputStream);
                string str = reader.ReadToEnd();

                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                //获取到注册信息
                string ResultCode = string.Empty;
                var jarr = jsSerializer.Deserialize<Dictionary<String, object>>(str);
                if (jarr == null || jarr["role"].Equals(string.Empty))
                {
                    ResultCode = "2001";
                    dict.Add("ResultCode", ResultCode);
                    context.Response.Write(jsSerializer.Serialize(dict));
                    return;
                }
                string roleStr = jarr["role"].ToString();
                string useridStr = jarr["userid"].ToString();
                string usernameStr = jarr["username"].ToString();
                string userpwdStr = jarr["userpwd"].ToString();
                string addressStr = jarr["address"].ToString();
                string tokenStr = Guid.NewGuid().ToString();
                if (roleStr.Equals("parent"))
                {
                    UserInfo userInfo = new UserInfo();
                    userInfo.userid = useridStr;
                    userInfo.username = usernameStr;
                    userInfo.userpwd = Utils.GetMD5FromString(userpwdStr);
                    userInfo.address = addressStr;
                    userInfo.accesstoken = tokenStr;
                    BLLUsers bllUsers = new BLLUsers();
                    ResultCode = bllUsers.RegisterParent(userInfo);

                }
                else
                {
                    DriverModel driverInfo = new DriverModel();
                    driverInfo.driverid = useridStr;
                    driverInfo.drivername = usernameStr;
                    driverInfo.driverpwd = Utils.GetMD5FromString(userpwdStr);
                    driverInfo.address = addressStr;
                    driverInfo.accesstoken = tokenStr;
                    BLLDrivers bllDrivers = new BLLDrivers();
                    ResultCode = bllDrivers.RegisterDriver(driverInfo);
                }
                Utils.WriteTraceLog("register ResultCode:" + ResultCode);
                dict.Add("ResultCode", ResultCode);
                context.Response.Write(jsSerializer.Serialize(dict));
            }
            catch(Exception ex)
            {
                string str = ex.StackTrace;
                Utils.WriteTraceLog("register Exception:" + str);
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.Write(jsSerializer.Serialize(dict));
            }

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