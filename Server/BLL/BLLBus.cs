using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using DAL;
using System.Data;
using Common;

namespace BLL
{
    public class BLLBus
    {
        private DalTableBus dalTableBus;
        public BLLBus()
        {
            dalTableBus = new DalTableBus();
        }

        public bool IsBusNameExists(string busname)
        {
            return dalTableBus.IsBusNameExists(busname);
        }

        /// <summary>
        /// insert bus info
        /// </summary>
        /// <param name="businfo"></param>
        /// <returns></returns>
        public bool InsertBusInfo(BusInfo busInf)
        {
            int no = dalTableBus.GenNextNo();
            return dalTableBus.InsertBusInfo(busInf, no);
        }

        /// <summary>
        /// get all bus info
        /// </summary>
        /// <returns></returns>
        public List<BusInfo> getAllBusInfo()
        {
            DataTable dataTable = dalTableBus.getAllBusInfo();
            if (dataTable.Rows.Count > 0)
            {
                List<BusInfo> busInfoList = new List<BusInfo>();
                for (int i = 0; i < dataTable.Rows.Count; i++)
                {
                    if (!dataTable.Rows[i]["busid"].ToString().Equals(string.Empty))
                    {
                        BusInfo busInfo = new BusInfo();
                        busInfo.busid = dataTable.Rows[i]["busid"].ToString();
                        busInfo.buspwd = dataTable.Rows[i]["buspwd"].ToString();
                        busInfo.driverid = dataTable.Rows[i]["driverid"].ToString();
                        busInfo.useridlist = dataTable.Rows[i]["useridlist"].ToString();
                        busInfo.busname = dataTable.Rows[i]["busname"].ToString();
                        busInfoList.Add(busInfo);
                    }
                }
                return busInfoList;
            }
            return null;
        }

        /// <summary>
        /// get bus info by driverid
        /// </summary>
        /// <param name="driverid"></param>
        /// <returns></returns>
        public List<BusInfo> getBusInfoByDriverID(string driverid)
        {
            DataTable dataTable = dalTableBus.getBusInfoByDriverID(driverid);
            if (dataTable.Rows.Count > 0)
            {
                List<BusInfo> busInfoList = new List<BusInfo>();
                for (int i = 0; i < dataTable.Rows.Count; i++)
                {
                    if (!dataTable.Rows[i]["busid"].ToString().Equals(string.Empty))
                    {
                        BusInfo busInfo = new BusInfo();
                        busInfo.busid = dataTable.Rows[i]["busid"].ToString();
                        busInfo.buspwd = dataTable.Rows[i]["buspwd"].ToString();
                        busInfo.driverid = dataTable.Rows[i]["driverid"].ToString();
                        busInfo.useridlist = dataTable.Rows[i]["useridlist"].ToString();
                        busInfo.busname = dataTable.Rows[i]["busname"].ToString();
                        busInfoList.Add(busInfo);
                    }
                }
                return busInfoList;
            }
            return null;
        }

        /// <summary>
        /// get bus info by driverid
        /// </summary>
        /// <param name="driverid"></param>
        /// <returns></returns>
        public BusInfo getBusInfoByBusID(string busid)
        {
            DataTable dataTable = dalTableBus.getBusInfoByBusID(busid);
            if (dataTable.Rows.Count > 0)
            {
                if (!dataTable.Rows[0]["busid"].ToString().Equals(string.Empty))
                    {
                        BusInfo busInfo = new BusInfo();
                        busInfo.busid = dataTable.Rows[0]["busid"].ToString();
                        busInfo.buspwd = dataTable.Rows[0]["buspwd"].ToString();
                        busInfo.driverid = dataTable.Rows[0]["driverid"].ToString();
                        busInfo.useridlist = dataTable.Rows[0]["useridlist"].ToString();
                        busInfo.busname = dataTable.Rows[0]["busname"].ToString();
                        return busInfo;
                    }
                return null;
            }
            return null;
        }

        /// <summary>
        /// get useridlist by busid
        /// </summary>
        /// <param name="busid"></param>
        /// <returns></returns>
        public string[] getUserIDListByBusID(string busid)
        {
            string liststring = dalTableBus.getUserIDListByBusID(busid);
            if (liststring ==null || liststring ==string.Empty)
            {
                return null;
            }
            return liststring.Split(',');
        }

        public string getStringUserIDListByBusID(string busid)
        {
            string liststring = dalTableBus.getUserIDListByBusID(busid);
            if (liststring == null || liststring == string.Empty)
            {
                return null;
            }
            return liststring;
        }


        ///<summary>
        ///Verify password 
        ///</summary>
        /// <param name="busid"></param>
        /// <param name="buspwd"></param>
        /// <returns></returns>
        public bool verifyBusPwd(string busid, string buspwd)
        {
            return dalTableBus.verifyBusPwd(busid,buspwd);
        }


        ///<summary>
        ///update userid list 
        ///</summary>
        /// <param name="useridlist"></param>
        /// <returns></returns>
        public int updateUseridList(string busid, string[] useridlist)
        {
            string liststring = string.Join(",", useridlist);
            return dalTableBus.updateUseridList(busid, liststring);
        }

        public int updateStringUseridList(string busid, string useridlist)
        {
            return dalTableBus.updateUseridList(busid, useridlist);
        }

        public BusInfo driverAddVehicle(string driverid,string busname)
        {
            BusInfo busInfo = new BusInfo();
            busInfo.driverid = driverid;
            busInfo.busname = busname;
            busInfo.busid = string.Empty;
            busInfo.buspwd = string.Empty;
            busInfo.useridlist = string.Empty;
            List<BusInfo> busList = getBusInfoByDriverID(driverid);
            if (busList == null)
            {
                busInfo.busid = driverid + "_" + "bus" + "001";
            }
            else
            {
                string lastBusID = busList[busList.Count-1].busid;
                string[] idArray = lastBusID.Split('_');
                string busno = idArray[idArray.Length - 1].Substring(3);
                int busNoInt = int.Parse(busno);
                if (busNoInt ==999)
                {
                    return null;
                }
                busNoInt = busNoInt + 1;
                busInfo.busid = driverid + "_" + "bus" + busNoInt.ToString().PadLeft(3,'0');
            }
            busInfo.buspwd = Utils.getRandomPassword();
            bool result = InsertBusInfo(busInfo);
            if (result)
            {
                return busInfo;
            }
            else
            {
                return null;
            }
        }
        public bool deleteSelectedVehicleByPatient(string userid, string busid)
        {
            if (getUserIDListByBusID(busid) ==null)
            {
                return true;
            }
            List<string> userIDList = getUserIDListByBusID(busid).ToList();
            for (int i = 0; i < userIDList.Count; i++)
            {
                if (userIDList[i].Equals(userid))
                {
                    userIDList.Remove(userid);
                }
            }
            int row = updateUseridList(busid, userIDList.ToArray());
            if (row >0)
            {
                return true;
            }
            return false;
        }

        public bool deleteBusInfoByBusID(string busid)
        {
            return dalTableBus.deleteBusInfoByBusID(busid);
        }
    }
}
