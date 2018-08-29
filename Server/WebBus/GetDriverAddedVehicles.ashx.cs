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
    /// requestDriverAddedVehicles 的摘要说明
    /// </summary>
    public class GetDriverAddedVehicles : IHttpHandler
    {
        private class RequestData
        {
            public string AccessToken { get; set; }
            public string DriverID { get; set; }
        }

        public void ProcessRequest(HttpContext context)
        {
            try
            {
                Utils.WriteTraceLog("GetDriverAddedVehicles start");
                StreamReader reader = new StreamReader(context.Request.InputStream);
                string str = reader.ReadToEnd();
                reader.Close();
                string ResultCode = string.Empty;
                BLLDrivers bLLDrivers = new BLLDrivers();
                BLLBus bLLBus = new BLLBus();
                Dictionary<string, object> dict = new Dictionary<string, object>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                RequestData requestData = jsSerializer.Deserialize<RequestData>(str);
                if (requestData == null)
                {
                    ResultCode = "2201";
                }
                else if (requestData.AccessToken == string.Empty || requestData.AccessToken == null)
                {
                    ResultCode = "2202";
                }
                else if (requestData.DriverID == string.Empty || requestData.DriverID == null)
                {
                    ResultCode = "2203";
                }
                else if (!bLLDrivers.verifyDriverID(requestData.DriverID, requestData.AccessToken))
                {
                    ResultCode = "2204";
                }
                else if (bLLBus.getBusInfoByDriverID(requestData.DriverID) == null)
                {
                    ResultCode = "2205";
                }
                else
                {
                    ResultCode = "0000";
                    List<BusInfo> busList = bLLBus.getBusInfoByDriverID(requestData.DriverID);
                    string[] busArray = new string[busList.Count];
                    for (int i = 0; i < busArray.Length; i++)
                    {
                        Dictionary<string, string> dictionary = new Dictionary<string, string>();
                        dictionary.Add("BusID", busList[i].busid);
                        dictionary.Add("BusPWD", busList[i].buspwd);
                        dictionary.Add("BusName", busList[i].busname);
                        busArray[i] = jsSerializer.Serialize(dictionary);
                    }
                    dict.Add("VehiclesArray", busArray);
                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("GetDriverAddedVehicles ResultCode====" + ResultCode);
                Utils.WriteTraceLog("GetDriverAddedVehicles end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("GetDriverAddedVehicles Exception " + ex);
                Utils.WriteTraceLog("GetDriverAddedVehicles ResultCode====9991");
                Utils.WriteTraceLog("GetDriverAddedVehicles end");
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