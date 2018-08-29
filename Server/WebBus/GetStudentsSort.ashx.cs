using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Web.Script.Serialization;
using BLL;
using Model;
using Common;

namespace WebBus
{
    /// <summary>
    /// requestStudentsSort 的摘要说明
    /// </summary>
    public class GetStudentsSort : IHttpHandler
    {
        private class RequestData
        {
            public string AccessToken { get; set; }
            public string DriverID { get; set; }
            public string BusID { get; set; }
        }
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                Utils.WriteTraceLog("GetStudentsSort start");
                StreamReader reader = new StreamReader(context.Request.InputStream);
                string str = reader.ReadToEnd();
                reader.Close();
                string ResultCode = string.Empty;
                BLLDrivers bLLDrivers = new BLLDrivers();
                BLLBus bLLBus = new BLLBus();
                BLLUsers bLLUsers = new BLLUsers();
                Dictionary<string, object> dict = new Dictionary<string, object>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                RequestData requestData = jsSerializer.Deserialize<RequestData>(str);
                if (requestData == null)
                {
                    ResultCode = "2401";
                }
                else if (requestData.AccessToken == string.Empty || requestData.AccessToken == null)
                {
                    ResultCode = "2402";
                }
                else if (requestData.DriverID == string.Empty || requestData.DriverID == null)
                {
                    ResultCode = "2403";
                }
                else if (!bLLDrivers.verifyDriverID(requestData.DriverID, requestData.AccessToken))
                {
                    ResultCode = "2404";
                }
                else if (requestData.BusID == string.Empty || requestData.BusID == null)
                {
                    ResultCode = "2405";
                }

                else
                {
                    string[] userIDArray = bLLBus.getUserIDListByBusID(requestData.BusID);
                    if (userIDArray == null)
                    {
                        ResultCode = "2406";
                    }
                    else
                    {
                        ResultCode = "0000";
                        string[] userInfoArray = new string[userIDArray.Length];
                        for (int i = 0; i < userIDArray.Length; i++)
                        {
                            UserInfo userInfo = bLLUsers.GetuserInfo(userIDArray[i]);
                            Dictionary<string, string> dictionary = new Dictionary<string, string>();
                            dictionary.Add("StudentID", userInfo.userid);
                            dictionary.Add("StudentName", userInfo.username);
                            dictionary.Add("FamilyAddress", userInfo.address);
                            userInfoArray[i] = jsSerializer.Serialize(dictionary);
                        }
                        dict.Add("StudentsSortArray", userInfoArray);
                    }
                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("GetStudentsSort ResultCode====" + ResultCode);
                Utils.WriteTraceLog("GetStudentsSort end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("GetStudentsSort Exception " + ex);
                Utils.WriteTraceLog("GetStudentsSort ResultCode====9991");
                Utils.WriteTraceLog("GetStudentsSort end");
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