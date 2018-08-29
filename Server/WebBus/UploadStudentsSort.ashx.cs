using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Web.Script.Serialization;
using BLL;
using Model;
using System.Collections;
using Common;

namespace WebBus
{
    /// <summary>
    /// requestUpdateStudentsSort 的摘要说明
    /// </summary>
    public class UploadStudentsSort : IHttpHandler
    {
        private class RequestArrayData
        {
            public string StudentID { get; set; }
        }

        private class RequestData
        {
            public string AccessToken { get; set; }
            public string DriverID { get; set; }
            public string BusID { get; set; }
            public ArrayList StudentsSortArray { get; set; }
            public ArrayList StudentsSortData { get; set; }
        }

        public void ProcessRequest(HttpContext context)
        {
            try
            {
                Utils.WriteTraceLog("UploadStudentsSort start");
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
                    ResultCode = "2501";
                }
                else if (requestData.AccessToken == string.Empty || requestData.AccessToken == null)
                {
                    ResultCode = "2502";
                }
                else if (requestData.DriverID == string.Empty || requestData.DriverID == null)
                {
                    ResultCode = "2503";
                }
                else if (!bLLDrivers.verifyDriverID(requestData.DriverID, requestData.AccessToken))
                {
                    ResultCode = "2504";
                }
                else if (requestData.BusID == string.Empty || requestData.BusID == null)
                {
                    ResultCode = "2505";
                }
                else if (requestData.StudentsSortArray == null || requestData.StudentsSortArray.Count == 0)
                {
                    ResultCode = "2506";
                }
                else
                {
                    ArrayList tmpArrList = new ArrayList();
                    foreach (object item in requestData.StudentsSortArray)
                    {
                        RequestArrayData requestArrayData = jsSerializer.Deserialize<RequestArrayData>(item.ToString());
                        tmpArrList.Add(requestArrayData);
                    }
                    requestData.StudentsSortData = tmpArrList;
                    int j = 0;
                    string[] useridList = new string[requestData.StudentsSortData.Count];
                    foreach (RequestArrayData dataItem in requestData.StudentsSortData)
                    {
                        useridList[j] = dataItem.StudentID;
                        j++;
                    }
                    int row = bLLBus.updateUseridList(requestData.BusID, useridList);
                    if (row > 0)
                    {
                        ResultCode = "0000";
                    }
                    else
                    {
                        ResultCode = "2507";
                    }
                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("UploadStudentsSort ResultCode====" + ResultCode);
                Utils.WriteTraceLog("UploadStudentsSort end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("UploadStudentsSort Exception " + ex);
                Utils.WriteTraceLog("UploadStudentsSort ResultCode====9991");
                Utils.WriteTraceLog("UploadStudentsSort end");
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