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
    /// requestAllVehicles 的摘要说明
    /// </summary>
    public class GetAllVehicles : IHttpHandler
    {
        private class RequestData
        {
            public string AccessToken { get; set; }
            public string ParentID { get; set; }
        }
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                Utils.WriteTraceLog("GetAllVehicles start");
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
                    ResultCode = "2601";
                }
                else if (requestData.AccessToken == string.Empty || requestData.AccessToken == null)
                {
                    ResultCode = "2602";
                }
                else if (requestData.ParentID == string.Empty || requestData.ParentID == null)
                {
                    ResultCode = "2603";
                }
                else if (!bLLUsers.verifyUserID(requestData.ParentID, requestData.AccessToken))
                {
                    ResultCode = "2604";
                }
                else
                {
                    List<BusInfo> busInfoList = bLLBus.getAllBusInfo();
                    if (busInfoList == null)
                    {
                        ResultCode = "2605";
                    }
                    else
                    {
                        ResultCode = "0000";
                        string[] busArray = new string[busInfoList.Count];
                        for (int i = 0; i < busArray.Length; i++)
                        {
                            Dictionary<string, string> dictionary = new Dictionary<string, string>();
                            dictionary.Add("BusID", busInfoList[i].busid);
                            dictionary.Add("BusName", busInfoList[i].busname);
                            busArray[i] = jsSerializer.Serialize(dictionary);
                        }
                        dict.Add("AllVehiclesArray", busArray);
                    }
                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("GetAllVehicles ResultCode====" + ResultCode);
                Utils.WriteTraceLog("GetAllVehicles end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("GetAllVehicles Exception " + ex);
                Utils.WriteTraceLog("GetAllVehicles ResultCode====9991");
                Utils.WriteTraceLog("GetAllVehicles end");
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