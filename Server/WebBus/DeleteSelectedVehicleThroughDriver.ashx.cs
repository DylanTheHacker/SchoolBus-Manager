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
    /// DeleteSelectedVehicleThroughDriver 的摘要说明
    /// </summary>
    public class DeleteSelectedVehicleThroughDriver : IHttpHandler
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
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughDriver start");
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
                    ResultCode = "3301";
                }
                else if (requestData.AccessToken == string.Empty || requestData.AccessToken == null)
                {
                    ResultCode = "3302";
                }
                else if (requestData.DriverID == string.Empty || requestData.DriverID == null)
                {
                    ResultCode = "3303";
                }
                else if (!bLLDrivers.verifyDriverID(requestData.DriverID, requestData.AccessToken))
                {
                    ResultCode = "3304";
                }
                else if (requestData.BusID == string.Empty || requestData.BusID == null)
                {
                    ResultCode = "3305";
                }

                else
                {
                    bool result = false;
                    string[] userIDList = bLLBus.getUserIDListByBusID(requestData.BusID);
                    if (userIDList ==null)
                    {
                        result = bLLBus.deleteBusInfoByBusID(requestData.BusID);
                        ResultCode = "0000";
                    }
                    else
                    {
                        for (int i = 0; i < userIDList.Length;i++ )
                        {
                            bLLUsers.deleteSelectedVehicle(userIDList[i], requestData.BusID);
                        }
                        result = bLLBus.deleteBusInfoByBusID(requestData.BusID);
                        ResultCode = "0000";
                    }
                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughDriver ResultCode====" + ResultCode);
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughDriver end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughDriver Exception " + ex);
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughDriver ResultCode====9991");
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughDriver end");
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