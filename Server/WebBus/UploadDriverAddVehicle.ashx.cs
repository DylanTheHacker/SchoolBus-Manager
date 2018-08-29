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
    /// requestDriverAddVehicle 的摘要说明
    /// </summary>
    public class UploadDriverAddVehicle : IHttpHandler
    {
        private class RequestData
        {
            public string AccessToken { get; set; }
            public string DriverID { get; set; }
            public string BusName { get; set; }
        }
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                Utils.WriteTraceLog("UploadDriverAddVehicle start");
                StreamReader reader = new StreamReader(context.Request.InputStream);
                string str = reader.ReadToEnd();
                reader.Close();
                string ResultCode = string.Empty;
                BLLDrivers bLLDrivers = new BLLDrivers();
                BLLBus bLLBus = new BLLBus();
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                RequestData requestData = jsSerializer.Deserialize<RequestData>(str);
                if (requestData == null)
                {
                    ResultCode = "2301";
                }
                else if (requestData.AccessToken == string.Empty || requestData.AccessToken == null)
                {
                    ResultCode = "2302";
                }
                else if (requestData.DriverID == string.Empty || requestData.DriverID == null)
                {
                    ResultCode = "2303";
                }
                else if (!bLLDrivers.verifyDriverID(requestData.DriverID, requestData.AccessToken))
                {
                    ResultCode = "2304";
                }
                else if (requestData.BusName == string.Empty || requestData.BusName == null)
                {
                    ResultCode = "2306";
                }
                else if(bLLBus.IsBusNameExists(requestData.BusName))
                {
                    ResultCode = "2307";
                }
                else
                {
                    BusInfo newBusInfo = bLLBus.driverAddVehicle(requestData.DriverID,requestData.BusName);
                    if (newBusInfo == null)
                    {
                        ResultCode = "2305";
                    }
                    else
                    {
                        ResultCode = "0000";
                        dict.Add("BusID", newBusInfo.busid);
                        dict.Add("BusPWD", newBusInfo.buspwd);
                        dict.Add("BusName",newBusInfo.busname);
                    }
                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("UploadDriverAddVehicle ResultCode====" + ResultCode);
                Utils.WriteTraceLog("UploadDriverAddVehicle end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("UploadDriverAddVehicle Exception " + ex);
                Utils.WriteTraceLog("UploadDriverAddVehicle ResultCode====9991");
                Utils.WriteTraceLog("UploadDriverAddVehicle end");
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