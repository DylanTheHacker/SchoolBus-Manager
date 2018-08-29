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
    /// DeleteSelectedVehicleThroughParent 的摘要说明
    /// </summary>
    public class DeleteSelectedVehicleThroughParent : IHttpHandler
    {
        private class RequestData
        {
            public string AccessToken { get; set; }
            public string ParentID { get; set; }
            public string BusID { get; set; }
        }
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughParent start");
                StreamReader reader = new StreamReader(context.Request.InputStream);
                string str = reader.ReadToEnd();
                reader.Close();
                string ResultCode = string.Empty;
                BLLBus bLLBus = new BLLBus();
                BLLUsers bLLUsers = new BLLUsers();
                Dictionary<string, object> dict = new Dictionary<string, object>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                RequestData requestData = jsSerializer.Deserialize<RequestData>(str);
                if (requestData == null)
                {
                    ResultCode = "3401";
                }
                else if (requestData.AccessToken == string.Empty || requestData.AccessToken == null)
                {
                    ResultCode = "3402";
                }
                else if (requestData.ParentID == string.Empty || requestData.ParentID == null)
                {
                    ResultCode = "3403";
                }
                else if (!bLLUsers.verifyUserID(requestData.ParentID, requestData.AccessToken))
                {
                    ResultCode = "3404";
                }
                else if (requestData.BusID == string.Empty || requestData.BusID == null)
                {
                    ResultCode = "3405";
                }
                else
                {
                    bool result =  bLLUsers.deleteSelectedVehicle(requestData.ParentID, requestData.BusID);
                    if (result)
                    {
                        result = bLLBus.deleteSelectedVehicleByPatient(requestData.ParentID, requestData.BusID);
                        ResultCode = "0000";
                    }
                    else
                    {
                        ResultCode = "3406";
                    }

                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughParent ResultCode====" + ResultCode);
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughParent end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughParent Exception " + ex);
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughParent ResultCode====9991");
                Utils.WriteTraceLog("DeleteSelectedVehicleThroughParent end");
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