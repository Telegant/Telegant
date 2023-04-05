from setuptools import setup, find_packages
import os

with open(os.path.join(os.path.abspath(os.path.dirname(__file__)), 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

setup( 
    name='Telegant',
    version='0.2.1',
    description='An Elegant Modern Bot Framework for Python',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://github.com/kotov584/Telegant',
    author='Kotov584', 
    license='MIT', 
    keywords='python, telegram, bot, api, async, asynchronous, elegant, modern',
    packages=find_packages(),
    install_requires=[
        "aiohttp"
    ],
    python_requires='>=3.6',
)
