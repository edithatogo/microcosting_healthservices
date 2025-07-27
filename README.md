# Academic Project Page Template
This is an academic paper project page template.

## Installation

Some of the helper scripts use Python. Install the required packages with:

```bash
pip install pandas pyxlsb
```


Example project pages built using this template are:
- https://horwitz.ai/probex
- https://vision.huji.ac.il/probegen
- https://horwitz.ai/mother
- https://horwitz.ai/spectral_detuning
- https://vision.huji.ac.il/ladeda
- https://vision.huji.ac.il/dsire
- https://horwitz.ai/podd
- https://dreamix-video-editing.github.io
- https://horwitz.ai/conffusion
- https://horwitz.ai/3d_ads/
- https://vision.huji.ac.il/ssrl_ad
- https://vision.huji.ac.il/deepsim

## Data extraction and funding calculator

### Regenerating `excel_calculator/data/weights.csv`
Run the following command from the repository root to rebuild the weights table:

```bash
python excel_calculator/scripts/extract_weights.py
```

This reads `excel_calculator/archive/nwau25_calculator_for_acute_activity.xlsb` and writes the result to `excel_calculator/data/weights.csv`.

### Editing `formula.json`
`excel_calculator/data/formula.json` stores the pricing formula. The `variables` mapping links symbols used in the workbook to column names in `excel_calculator/data/weights.csv`. The `steps` array lists the intermediate calculations that lead to the final `NWAU25` value. Adjust these entries if the source workbook changes.

### Example usage of `funding_calculator.py`
`excel_calculator/src/funding_calculator.py` applies the formula to patient level data. A typical invocation is:

```bash
python excel_calculator/src/funding_calculator.py \
    --weights excel_calculator/data/weights.csv \

    --formula excel_calculator/data/formula.json patient_data.csv > funding.csv
```

### Tests
Unit tests are provided under the `tests/` and `excel_calculator/tests/` folders.
After installing the dependencies from `requirements.txt`, run them with:

```bash
pytest -v
```

## Start using the template
To start using the template click on `Use this Template`.

The template uses html for controlling the content and css for controlling the style. 
To edit the websites contents edit the `index.html` file. It contains different HTML "building blocks", use whichever ones you need and comment out the rest.  

**IMPORTANT!** Make sure to replace the `favicon.ico` under `static/images/` with one of your own, otherwise your favicon is going to be a dreambooth image of me.

## Components
- Teaser video
- Images Carousel
- Youtube embedding
- Video Carousel
- PDF Poster
- Bibtex citation

## Tips:
- The `index.html` file contains comments instructing you what to replace, you should follow these comments.
- The `meta` tags in the `index.html` file are used to provide metadata about your paper 
(e.g. helping search engine index the website, showing a preview image when sharing the website, etc.)
- The resolution of images and videos can usually be around 1920-2048, there rarely a need for better resolution that take longer to load. 
- All the images and videos you use should be compressed to allow for fast loading of the website (and thus better indexing by search engines). For images, you can use [TinyPNG](https://tinypng.com), for videos you can need to find the tradeoff between size and quality.
- When using large video files (larger than 10MB), it's better to use youtube for hosting the video as serving the video from the website can take time.
- Using a tracker can help you analyze the traffic and see where users came from. [statcounter](https://statcounter.com) is a free, easy to use tracker that takes under 5 minutes to set up. 
- This project page can also be made into a github pages website.
- Replace the favicon to one of your choosing (the default one is of the Hebrew University). 
- Suggestions, improvements and comments are welcome, simply open an issue or contact me. You can find my contact information at [https://horwitz.ai](https://horwitz.ai)

## Acknowledgments
Parts of this project page were adopted from the [Nerfies](https://nerfies.github.io/) page.

## Website License
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
