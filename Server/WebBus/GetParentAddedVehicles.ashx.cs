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
    /// requestParentAddedVehicles 的摘要说明
    /// </summary>
    public class GetParentAddedVehicles : IHttpHandler
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
                Utils.WriteTraceLog("GetParentAddedVehicles start");
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
                    ResultCode = "2701";
                }
                else if (requestData.AccessToken == string.Empty || requestData.AccessToken == null)
                {
                    ResultCode = "2702";
                }
                else if (requestData.ParentID == string.Empty || requestData.ParentID == null)
                {
                    ResultCode = "2703";
                }
                else if (!bLLUsers.verifyUserID(requestData.ParentID, requestData.AccessToken))
                {
                    ResultCode = "2704";
                }
                else
                {
                    UserInfo userInfo = bLLUsers.GetuserInfo(requestData.ParentID);
                    if (userInfo.busarray == null)
                    {
                        ResultCode = "2705";
                    }
                    else
                    {
                        ResultCode = "0000";
                        string[] buss = userInfo.busarray.Split(',');
                        List<string> busArray = new List<string>();
                        for (int i = 0; i < buss.Length; i++)
                        {
                            if (!buss[i].Equals(string.Empty))
                            {
                                BusInfo busInfo = bLLBus.getBusInfoByBusID(buss[i]);
                                if (busInfo !=null)
                                {
                                    Dictionary<string, string> dictionary = new Dictionary<string, string>();
                                    dictionary.Add("BusID", busInfo.busid);
                                    dictionary.Add("BusName", busInfo.busname);
                                    busArray.Add(jsSerializer.Serialize(dictionary));
                                }
                            }
                        }
                        dict.Add("AddedVehiclesArray", busArray.ToArray());
                        dict.Add("SelectedVehicleBusID", userInfo.selectbusid);
                    }
                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("GetParentAddedVehicles ResultCode====" + ResultCode);
                Utils.WriteTraceLog("GetParentAddedVehicles end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("GetParentAddedVehicles Exception " + ex);
                Utils.WriteTraceLog("GetParentAddedVehicles ResultCode====9991");
                Utils.WriteTraceLog("GetParentAddedVehicles end");
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