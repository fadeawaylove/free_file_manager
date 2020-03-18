import re
import os
import urllib
import time
import asyncio
import aiohttp
import traceback
import sys
import threading
import ssl
import certifi

import requests
from lxml import etree

loop = asyncio.get_event_loop()


class CheChiSpider(object):
    semaphore = asyncio.Semaphore(10)
    _ssl_context = ssl.create_default_context(cafile=certifi.where())
    http_session = aiohttp.ClientSession(loop=loop)

    @classmethod
    async def _get_resp(cls, url, raw=False):
        try:
            print("aiohttp请求： {}".format(url))
            async with cls.http_session.get(url, ssl=cls._ssl_context) as resp:
                if raw:
                    return await resp.read()
                data = await resp.text()
                print("获取成功： {}".format(url))
                return data
        except:
            # print(traceback.format_exc())
            print("aiohttp请求失败： {}".format(url))
            print("使用requests重新请求中... ")
            task = loop.run_in_executor(None, requests.get, url)
            if raw:
                data = (await task).content
            else:
                data = (await task).text
            print("使用requests重新请求成功： {}".format(url))
            return data

    @classmethod
    async def get_origin_m3u8_url_list(cls, video_url):
        """从页面获取原始的m3u8的url"""
        resp_content = await cls._get_resp(video_url)
        html = etree.HTML(resp_content)
        origin_infos = html.xpath("""//div[@class="main"]/script""")[0].text
        origin_urls = re.findall(r"unescape\(\'(.*?)\'\)", origin_infos)[0]
        parsed_urls = urllib.parse.unquote(origin_urls).split(r"$$$")
        for p in parsed_urls:
            if "index.m3u8" in p:
                parsed_urls = p
                break
        m3u8_url_list = re.findall(r"https:\/.*?\/index.m3u8", parsed_urls)
        return m3u8_url_list

    @classmethod
    async def get_real_m3u8_url(cls, m3_url):
        """从原始的m3u8的url获取真实的m3u8url"""
        resp_text = await cls._get_resp(m3_url)
        url_path = resp_text.split("\n")[-1]
        new_m3u8_url = cls.repalce_url_end_path(m3_url, url_path)
        return new_m3u8_url

    @classmethod
    async def get_ts(cls, real_m3url):
        """从m3u8的url获取其中的ts文件地址"""
        ts_infos = await cls._get_resp(real_m3url)
        all_ts_path = re.findall(r"(.*?\.ts)", ts_infos)
        full_all_ts_path = [cls.repalce_url_end_path(real_m3url, x) for x in all_ts_path]
        return full_all_ts_path

    @classmethod
    def download_from_m3u8(cls, m3u8_url, dir_path, file_name):
        file_path = "{}/{}.mp4".format(dir_path, file_name)
        if os.path.exists(file_path):
            return
        os.system(
            "ffmpeg -i {} -acodec copy -vcodec copy -absf aac_adtstoasc {}".format(m3u8_url, file_path))

    @classmethod
    async def _save_ts(cls, ts_url, ts_index, tmp_dir):
        os.makedirs(tmp_dir, exist_ok=True)
        ts_name = "{}.ts".format(ts_index)
        ts_path = os.path.join(tmp_dir, ts_name)
        if not os.path.exists(ts_path):
             # 限制下载ts文件时候的并发量
            async with cls.semaphore:
                ts_content = await cls._get_resp(ts_url, raw=True)
            with open(ts_path, "wb") as f:
                f.write(ts_content)
        return ts_path

    @classmethod
    async def _save_all_ts(cls, ts_url_list, tmp_dir):
        print("开始下载，数量：{} ==> {}".format(len(ts_url_list), tmp_dir))
        tasks = [asyncio.ensure_future(cls._save_ts(u, i, tmp_dir)) for i, u in enumerate(ts_url_list)]
        ret = await asyncio.gather(*tasks)
        print("完成下载:{}".format(tmp_dir))
        return ret

    @classmethod
    def _merge_ts_files(cls, future):
        ts_path_list = future.result()
        full_list = ts_path_list[0].split(r"/")
        out_path = "/".join(full_list[:-3]) + "/" + full_list[-2] + ".mp4"
        if os.path.exists(out_path):
            print("文件【{}】已经存在".format(out_path))
            return
        nnn = "|".join([str(x) for x in ts_path_list])
        command = """ffmpeg -i "concat:{}" -acodec copy -vcodec copy -absf aac_adtstoasc {}""".format(
            nnn, out_path)
        os.system(command)

    @classmethod
    def repalce_url_end_path(cls, url, end_path):
        a = url.split("/")[:-1]
        a.append(end_path)
        return "/".join(a)

    @classmethod
    async def run(cls, video_url, save_dir, semaphore_count=10):
        if semaphore_count:
            cls.semaphore = asyncio.Semaphore(semaphore_count)
        # 1、获取原始的m3u8的url地址
        origin_m3url = await cls.get_origin_m3u8_url_list(video_url)
        # 2、得到保存ts信息的地址
        m3u8_tasks = [asyncio.ensure_future(
            cls.get_real_m3u8_url(u)) for u in origin_m3url]
        real_m3u8_url_list = await asyncio.gather(*m3u8_tasks)
        # 3.解析并下载ts文件
        tmp_dir = os.path.join(save_dir, "tmp")
        ts_url_tasks = [asyncio.ensure_future(cls.get_ts(u)) for u in real_m3u8_url_list]
        all_ts_url = await asyncio.gather(*ts_url_tasks)
        ts_save_tasks = [asyncio.ensure_future(cls._save_all_ts(l, os.path.join(tmp_dir, str(i+1)))) for i, l in enumerate(all_ts_url)]
        for t in ts_save_tasks:
            t.add_done_callback(cls._merge_ts_files)
        await asyncio.gather(*ts_save_tasks)


if __name__ == "__main__":
    scount = 10
    fpath = os.getcwd()
    if len(sys.argv) not in (2, 3, 4):
        raise Exception("params count not right, require one or two params.")
    if len(sys.argv) == 4:
        _, vurl, fpath, scount = sys.argv
    if len(sys.argv) == 3:
        _, vurl, fpath = sys.argv
    elif len(sys.argv) == 2:
        _, vurl = sys.argv
    print(vurl, fpath)
    if not os.path.exists(fpath):
        os.makedirs(fpath, exist_ok=True)

    task = asyncio.ensure_future(CheChiSpider.run(vurl, fpath, int(scount)))
    loop.run_until_complete(task)
    loop.close()
